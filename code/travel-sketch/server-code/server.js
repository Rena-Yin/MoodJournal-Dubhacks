// Load API key: 
require('dotenv').config();  
console.log("Loaded API key:", process.env.API_KEY);  // <--- Add this

// Initializing server framework: 
const express = require('express');  
// To make HTTP requests: 
const axios = require('axios');     
// Communicate to the front-end: 
const cors = require('cors');       
const app = express();
const PORT = 8080;

// Enable CORS for all routes: 
app.use(cors());

// Load the Google Maps API key: 
const apiKey = process.env.API_KEY;

// Define a route to handle GET requests to /landmarks
app.get('/landmarks', async (req, res) => {
  // Extract latitude and longitude from the query parameters
  const { lat, lng } = req.query;

  // Construct URL. Landmarks for Place API = "Tourist Attractions"
  const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=32000&type=tourist_attraction&key=${apiKey}`;

  try {
    // Send a GET request to Google Places API
    const response = await axios.get(url);

    // Forward response to frontend 
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: err.toString() });
  }
});

// Start the server at port 8080
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});
