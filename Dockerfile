# Multi-stage build for Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-builder

# Set working directory
WORKDIR /app

# Copy Flutter project files
COPY pubspec.yaml pubspec.lock ./
COPY lib/ lib/
COPY web/ web/
COPY assets/ assets/

# Get dependencies and build web with better error handling
RUN flutter doctor --verbose
RUN flutter pub get
RUN flutter build web --release --verbose

# Production stage with Node.js
FROM node:18-alpine

# Set working directory
WORKDIR /workspace

# Copy package files first for better Docker layer caching
COPY package*.json ./

# Install Node.js dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy Flutter web build from previous stage
COPY --from=flutter-builder /app/build/web ./build/web

# Copy Node.js server
COPY index.js ./

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
RUN chown -R nodejs:nodejs /workspace
USER nodejs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080', (res) => { \
    if (res.statusCode === 200) process.exit(0); else process.exit(1); \
  }).on('error', () => process.exit(1));"

# Start the server
CMD ["npm", "start"] 