const express = require('express');
const path = require('path');
const app = express();

// Port from environment variable or default to 8080
const PORT = process.env.PORT || 8080;

// Serve static files from public directory (Flutter web build)
app.use(express.static(path.join(__dirname, 'public')));

// Handle Flutter web routing - serve index.html for all routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`🚀 Flutter Web app is running on port ${PORT}`);
  console.log(`📁 Serving files from: ${path.join(__dirname, 'public')}`);
}); 