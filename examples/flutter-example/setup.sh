#!/bin/bash

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Create Flutter project
flutter create . --platforms android,ios --org com.gomailer

# Get dependencies
flutter pub get

# Cleanup default example content
rm -f lib/main.dart.bak

echo "Flutter example project setup complete!"
