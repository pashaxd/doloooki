# Multi-stage build for Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-builder

# Set working directory
WORKDIR /app

# Copy Flutter project files
COPY pubspec.yaml pubspec.lock ./
COPY lib/ lib/
COPY web/ web/
COPY assets/ assets/

# Get dependencies and build web
RUN flutter pub get
RUN flutter build web --release

# Production stage with Node.js
FROM node:18-alpine

# Set working directory
WORKDIR /workspace

# Copy package files
COPY package*.json ./

# Install Node.js dependencies
RUN npm ci --only=production

# Copy Flutter web build from previous stage
COPY --from=flutter-builder /app/build/web ./build/web

# Copy Node.js server
COPY index.js ./

# Expose port
EXPOSE 8080

# Start the server
CMD ["npm", "start"] 