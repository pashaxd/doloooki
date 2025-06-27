# Flutter Web Development Commands

.PHONY: web web-debug web-release clean

# Run Flutter web on port 8080 (default)
web:
	flutter run -d chrome --web-port=8080

# Run Flutter web in debug mode
web-debug:
	flutter run -d chrome --web-port=8080 

# Run Flutter web in release mode  
web-release:
	flutter run -d chrome --web-port=8080 --release

# Clean build files
clean:
	flutter clean
	flutter pub get

# Build for web
build-web:
	flutter build web

# Install dependencies
deps:
	flutter pub get

# Run tests
test:
	flutter test 