const express = require('express');
const path = require('path');
const app = express();

// Port from environment variable or default to 8080
const PORT = process.env.PORT || 8080;

// Cache buster: 2025-06-27-20:26 - PUBLIC DIRECTORY FIX
console.log('🔧 Starting server with PUBLIC directory configuration...');
console.log('📁 Expected path:', path.join(__dirname, 'public'));

// Serve static files from public directory (Flutter web build)
app.use(express.static(path.join(__dirname, 'public')));

// Handle Flutter web routing - serve index.html for all routes
app.get('*', (req, res) => {
  const indexPath = path.join(__dirname, 'public', 'index.html');
  console.log('📄 Serving index.html from:', indexPath);
  res.sendFile(indexPath);
});

app.listen(PORT, () => {
  console.log(`🚀 Flutter Web app is running on port ${PORT}`);
  console.log(`📁 Serving files from: ${path.join(__dirname, 'public')}`);
}); 