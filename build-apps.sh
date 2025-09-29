#!/bin/bash

# Go-Mailer SDK Build Script for Team Distribution
# This script builds all example apps for easy team distribution

set -e

echo "🚀 Go-Mailer SDK Build Script"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}📱 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Create builds directory
mkdir -p builds

# Build React Native Example
print_status "Building React Native Example..."
cd examples/push_test_react_native_example

if command -v npx &> /dev/null; then
    echo "Installing React Native dependencies..."
    npm install
    
    # Build Android APK
    if [ -d "android" ]; then
        print_status "Building Android APK..."
        cd android
        if ./gradlew assembleRelease; then
            cp app/build/outputs/apk/release/app-release.apk ../../builds/GoMailer-ReactNative-Android.apk
            print_success "React Native Android APK built: builds/GoMailer-ReactNative-Android.apk"
        else
            print_error "Failed to build React Native Android APK"
        fi
        cd ..
    fi
    
    # Build iOS (requires Xcode and macOS)
    if [[ "$OSTYPE" == "darwin"* ]] && [ -d "ios" ]; then
        print_status "Installing iOS dependencies..."
        cd ios && pod install && cd ..
        
        print_status "Building iOS app..."
        if npx react-native run-ios --device 2>/dev/null; then
            print_success "React Native iOS built successfully"
        else
            print_warning "React Native iOS build requires device connection and Xcode setup"
        fi
    fi
else
    print_error "React Native CLI not found. Install with: npm install -g react-native-cli"
fi

cd ../..

# Build Flutter Example
print_status "Building Flutter Example..."
cd examples/push_test_flutter_example

if command -v flutter &> /dev/null; then
    echo "Installing Flutter dependencies..."
    flutter pub get
    
    # Build Android APK
    print_status "Building Flutter Android APK..."
    if flutter build apk --release; then
        cp build/app/outputs/flutter-apk/app-release.apk ../../builds/GoMailer-Flutter-Android.apk
        print_success "Flutter Android APK built: builds/GoMailer-Flutter-Android.apk"
    else
        print_error "Failed to build Flutter Android APK"
    fi
    
    # Build iOS (requires Xcode and macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Building Flutter iOS..."
        cd ios && pod install && cd ..
        
        if flutter build ios --release; then
            print_success "Flutter iOS built successfully"
            
            # Try to build IPA
            if flutter build ipa --release 2>/dev/null; then
                cp build/ios/ipa/*.ipa ../../builds/GoMailer-Flutter-iOS.ipa 2>/dev/null || true
                print_success "Flutter iOS IPA built: builds/GoMailer-Flutter-iOS.ipa"
            else
                print_warning "Flutter iOS IPA build requires proper code signing setup"
            fi
        else
            print_error "Failed to build Flutter iOS"
        fi
    fi
else
    print_error "Flutter not found. Install from: https://flutter.dev/docs/get-started/install"
fi

cd ../..

# Build Native Android Example
print_status "Building Native Android Example..."
cd examples/push_test_android_example

if [ -f "gradlew" ]; then
    print_status "Building Native Android APK..."
    if ./gradlew assembleRelease; then
        cp app/build/outputs/apk/release/app-release.apk ../../builds/GoMailer-Native-Android.apk
        print_success "Native Android APK built: builds/GoMailer-Native-Android.apk"
    else
        print_error "Failed to build Native Android APK"
    fi
else
    print_error "Native Android project not found or not properly set up"
fi

cd ../..

# Summary
echo ""
echo "🎉 Build Summary"
echo "================"
echo ""

if [ -d "builds" ]; then
    echo "Built apps are available in the builds/ directory:"
    ls -la builds/ | grep -v "^total" | grep -v "^d" | while read line; do
        filename=$(echo $line | awk '{print $9}')
        size=$(echo $line | awk '{print $5}')
        if [ ! -z "$filename" ]; then
            echo -e "${GREEN}  📱 $filename${NC} ($(numfmt --to=iec $size))"
        fi
    done
else
    print_warning "No builds directory created - check build errors above"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Test the apps on physical devices"
echo "2. Distribute via Firebase App Distribution, TestFlight, or direct sharing"
echo "3. Share the TEAM_DISTRIBUTION_GUIDE.md with your team"
echo ""
print_success "Build script completed!"
