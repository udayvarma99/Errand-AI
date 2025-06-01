// backend/src/services/googleMapsService.js
// Interacts with the Google Maps Platform APIs (Places API).

const { Client } = require("@googlemaps/google-maps-services-js");
const config = require('../config');

// Ensure API key is available
if (!config.googleMapsApiKey) {
    console.error("FATAL ERROR: GOOGLE_MAPS_API_KEY is not set in environment variables.");
    // Optionally throw error
    // throw new Error("GOOGLE_MAPS_API_KEY missing from environment variables.");
}

// Initialize Google Maps client only if key exists
const client = config.googleMapsApiKey ? new Client({}) : null;

const DEFAULT_SEARCH_RADIUS = 5000; // 5 kilometers (adjust as needed)
const MAX_DETAILS_FETCH = 5; // Limit Place Details lookups to control costs

/**
 * Finds relevant places using Google Places Text Search API and fetches details for top results.
 * @param {string} query - The search query (e.g., "plumber near Main St", "dentist").
 * @param {{lat: number, lng: number}} location - The latitude/longitude to bias search results around.
 * @param {number} [radius=DEFAULT_SEARCH_RADIUS] - The search radius in meters (effective only with location).
 * @returns {Promise<Array<object>>} - A promise resolving to an array of Place Details results objects.
 * @throws {Error} - Throws if Google Maps API call fails or no results are found.
 */
async function findPlaces(query, location, radius = DEFAULT_SEARCH_RADIUS) {
  if (!client) {
    throw new Error("Google Maps client not initialized due to missing API key.");
  }
  if (!query || typeof query !== 'string' || query.trim() === '') {
    throw new Error("Search query cannot be empty for findPlaces.");
  }
  // Location is strongly recommended for relevance, but proceed if missing (with warning)
  if (!location || typeof location.lat !== 'number' || typeof location.lng !== 'number') {
      console.warn("findPlaces called without valid location coordinates. Search results may be less relevant.");
  }

  console.log(`Searching Google Maps for '${query}'${location ? ` near {lat: ${location.lat}, lng: ${location.lng}}` : ''}`);

  try {
    // --- Step 1: Text Search ---
    const searchParams = {
        query: query,
        key: config.googleMapsApiKey,
    };
    // Add location bias only if valid coordinates are provided
    if (location && typeof location.lat === 'number' && typeof location.lng === 'number') {
        searchParams.location = `${location.lat},${location.lng}`; // Format as string "lat,lng"
        searchParams.radius = radius;
    }
     // Optional: Add region biasing (e.g., 'us') if desired
     // searchParams.region = 'us';

    const response = await client.textSearch({
      params: searchParams,
      timeout: 5000, // 5 seconds timeout for text search
    });

    // Check response status
    if (response.data.status === 'ZERO_RESULTS') {
      console.log("Google Maps TextSearch found no results for query:", query);
      return []; // Return empty array, not an error
    }
    if (response.data.status !== 'OK') {
        console.error("Google Maps TextSearch Error:", response.data.status, response.data.error_message);
        throw new Error(`Google Maps TextSearch failed: ${response.data.error_message || response.data.status}`);
    }

    console.log(`TextSearch found ${response.data.results.length} initial results. Fetching details for top ${Math.min(response.data.results.length, MAX_DETAILS_FETCH)}...`);

    // --- Step 2: Place Details Lookup (for phone numbers, hours, etc.) ---
    const detailedPlacesPromises = response.data.results
      .slice(0, MAX_DETAILS_FETCH) // Limit lookups
      .filter(place => place.place_id) // Ensure place has an ID
      .map(async (place) => {
        try {
          const detailResponse = await client.placeDetails({
            params: {
              place_id: place.place_id,
              // Specify fields needed to control costs: https://developers.google.com/maps/documentation/places/web-service/details#fields
              fields: ['name', 'formatted_address', 'international_phone_number', 'opening_hours', 'website', 'rating', 'user_ratings_total', 'geometry', 'place_id', 'business_status'],
              key: config.googleMapsApiKey,
            },
            timeout: 3000, // Shorter timeout for detail calls
          });

          if (detailResponse.data.status === 'OK' && detailResponse.data.result) {
            // Only return places that are operational (if status available)
            if(detailResponse.data.result.business_status && detailResponse.data.result.business_status !== 'OPERATIONAL'){
                 console.log(`Skipping non-operational place: ${detailResponse.data.result.name} (Status: ${detailResponse.data.result.business_status})`)
                 return null; // Filter this out later
            }
            return detailResponse.data.result;
          } else {
            console.warn(`Failed to get details for place_id ${place.place_id}: Status ${detailResponse.data.status}`);
            return null; // Indicate failure for this place
          }
        } catch (detailError) {
          console.error(`Error fetching details for place_id ${place.place_id}:`, detailError.response?.data || detailError.message);
          return null; // Indicate failure
        }
      });

    // Wait for all detail lookups to complete
    const detailedPlacesResults = await Promise.all(detailedPlacesPromises);

    // Filter out null results (failed lookups or non-operational places)
    const validDetailedPlaces = detailedPlacesResults.filter(place => place !== null);

    console.log(`Returning ${validDetailedPlaces.length} places with details.`);
    return validDetailedPlaces;

  } catch (error) {
    // Catch errors from the initial TextSearch or other issues
    console.error("Error in findPlaces service:", error.response?.data || error.message);
    // Check if it's a Google Maps specific error structure
     if (error.response && error.response.data && error.response.data.error_message) {
         throw new Error(`Google Maps API Error: ${error.response.data.error_message}`);
     } else if (error.message.includes('timeout')) {
         throw new Error("Google Maps API request timed out.");
     }
     // Rethrow a generic error or the original error if it's not specific
     throw error instanceof Error ? error : new Error("An unexpected error occurred while searching Google Maps.");
  }
}

module.exports = { findPlaces };