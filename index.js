const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();

// Port from environment variable or default to 8080
const PORT = process.env.PORT || 8080;

// Cache buster: 2025-06-27-20:35 - FULL DEBUG VERSION
console.log('🔧 Starting server with FULL DEBUG configuration...');
console.log('📁 Current directory:', __dirname);
console.log('📁 Expected public path:', path.join(__dirname, 'public'));

// Check if public directory exists
const publicDir = path.join(__dirname, 'public');
const indexFile = path.join(publicDir, 'index.html');

try {
  const publicExists = fs.existsSync(publicDir);
  const indexExists = fs.existsSync(indexFile);
  console.log('🔍 Public directory exists:', publicExists);
  console.log('🔍 Index.html exists:', indexExists);
  
  if (publicExists) {
    const files = fs.readdirSync(publicDir);
    console.log('📋 Files in public/:', files.slice(0, 10));
  }
  
  // Also check if build/web exists (for debugging)
  const buildWebDir = path.join(__dirname, 'build', 'web');
  const buildWebExists = fs.existsSync(buildWebDir);
  console.log('🔍 Build/web directory exists:', buildWebExists);
  
} catch (error) {
  console.error('❌ Error checking directories:', error.message);
}

// Serve static files from public directory (Flutter web build)
app.use(express.static(publicDir));

// Handle Flutter web routing - serve index.html for all routes
app.get('*', (req, res) => {
  console.log('📄 Request for:', req.path);
  console.log('📄 Serving index.html from:', indexFile);
  
  if (fs.existsSync(indexFile)) {
    res.sendFile(indexFile);
  } else {
    console.error('❌ Index.html not found at:', indexFile);
    res.status(404).send('Index.html not found');
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Flutter Web app is running on port ${PORT}`);
  console.log(`📁 Serving files from: ${publicDir}`);
}); 