#!/bin/bash

# Flutter Web Runner Script
# Automatically runs Flutter web on port 8080

echo "🚀 Starting Flutter Web on port 8080..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Check if Chrome is running on port 8080
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null; then
    echo "⚠️  Port 8080 is already in use. Killing existing process..."
    kill -9 $(lsof -t -i:8080) 2>/dev/null || true
    sleep 2
fi

# Run Flutter web with fixed port
flutter run -d chrome --web-port=8080

echo "✅ Flutter Web started successfully!" 