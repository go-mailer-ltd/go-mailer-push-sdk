# 🚀 Go Mailer SDK Deployment Guide - Step by Step

This guide will walk you through deploying all Go Mailer SDKs for public distribution. Perfect for beginners!

## 📋 Overview

You'll be publishing 4 SDKs to their respective package managers:
- **Flutter SDK** → pub.dev (Dart/Flutter packages)
- **React Native SDK** → npm (JavaScript/TypeScript packages)
- **iOS SDK** → CocoaPods (iOS libraries)
- **Android SDK** → Maven Central (Java/Kotlin libraries)

## 🎯 Prerequisites

Before you start, make sure you have:
- [ ] All SDKs are tested and working
- [ ] Documentation is complete
- [ ] You have accounts on all package managers
- [ ] Version numbers are consistent (currently 1.0.0)

---

## 📱 **1. Flutter SDK Deployment (pub.dev)**

### **Step 1.1: Create pub.dev Account**
1. Go to [pub.dev](https://pub.dev)
2. Sign in with your Google account
3. Complete your publisher profile

### **Step 1.2: Prepare Flutter SDK**
```bash
cd /Users/noguntuberu/app/go-mailer-mobile-push/sdk/flutter
```

### **Step 1.3: Update pubspec.yaml**
Edit `pubspec.yaml` and remove the publish restriction:
```yaml
# Remove this line:
# publish_to: none

# Make sure these are correct:
name: go_mailer
version: 1.0.0
description: Go Mailer SDK for Flutter - Cross-platform customer engagement messaging and push notifications
homepage: https://github.com/go-mailer/go-mailer-flutter
repository: https://github.com/go-mailer/go-mailer-flutter
issue_tracker: https://github.com/go-mailer/go-mailer-flutter/issues
documentation: https://docs.go-mailer.com/flutter
```

### **Step 1.4: Validate Package**
```bash
flutter pub publish --dry-run
```
This will check for issues without actually publishing.

### **Step 1.5: Publish to pub.dev**
```bash
flutter pub publish
```
Follow the prompts and confirm the publication.

### **Step 1.6: Verify Publication**
- Go to [pub.dev/packages/go_mailer](https://pub.dev/packages/go_mailer)
- Verify your package appears correctly
- Check that documentation renders properly

---

## ⚛️ **2. React Native SDK Deployment (npm)**

### **Step 2.1: Create npm Account**
1. Go to [npmjs.com](https://www.npmjs.com)
2. Create an account
3. Verify your email

### **Step 2.2: Login to npm**
```bash
cd /Users/noguntuberu/app/go-mailer-mobile-push/sdk/react-native
npm login
```
Enter your npm credentials.

### **Step 2.3: Update package.json**
Ensure `package.json` has correct information:
```json
{
  "name": "go-mailer",
  "version": "1.0.0",
  "description": "Go Mailer SDK for React Native - Cross-platform customer engagement messaging",
  "main": "lib/index.js",
  "types": "lib/index.d.ts",
  "homepage": "https://docs.go-mailer.com/react-native",
  "repository": {
    "type": "git",
    "url": "https://github.com/go-mailer/go-mailer-react-native.git"
  },
  "publishConfig": {
    "registry": "https://registry.npmjs.org/"
  }
}
```

### **Step 2.4: Build the Package**
```bash
npm run build
```
This compiles TypeScript to JavaScript.

### **Step 2.5: Test Package**
```bash
npm pack
```
This creates a `.tgz` file you can inspect.

### **Step 2.6: Publish to npm**
```bash
npm publish
```

### **Step 2.7: Verify Publication**
- Go to [npmjs.com/package/go-mailer](https://www.npmjs.com/package/go-mailer)
- Verify package information is correct
- Test installation: `npm install go-mailer`

---

## 🍎 **3. iOS SDK Deployment (CocoaPods)**

### **Step 3.1: Install CocoaPods Tools**
```bash
sudo gem install cocoapods-trunk
```

### **Step 3.2: Register with CocoaPods Trunk**
```bash
pod trunk register your-email@example.com 'Your Name' --description='Go Mailer SDK'
```
Check your email and click the verification link.

### **Step 3.3: Create Podspec File**
Create `GoMailer.podspec` in `/Users/noguntuberu/app/go-mailer-mobile-push/sdk/ios/`:

```ruby
Pod::Spec.new do |spec|
  spec.name         = "GoMailer"
  spec.version      = "1.0.0"
  spec.summary      = "Go Mailer SDK for iOS - Customer engagement messaging and push notifications"
  spec.description  = <<-DESC
    Go Mailer SDK provides cross-platform push notification functionality
    and customer engagement messaging for iOS applications.
  DESC

  spec.homepage     = "https://github.com/go-mailer/go-mailer-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Go Mailer Team" => "support@gomailer.com" }

  spec.platform     = :ios, "12.0"
  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/go-mailer/go-mailer-ios.git", :tag => "#{spec.version}" }
  spec.source_files = "GoMailer/Sources/**/*.swift"

  spec.framework    = "UIKit", "UserNotifications"
  spec.requires_arc = true

  spec.dependency "Firebase/Core"
  spec.dependency "Firebase/Messaging"
end
```

### **Step 3.4: Create LICENSE File**
Create `LICENSE` file in `/Users/noguntuberu/app/go-mailer-mobile-push/sdk/ios/`:
```
MIT License

Copyright (c) 2024 Go Mailer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### **Step 3.5: Validate Podspec**
```bash
cd /Users/noguntuberu/app/go-mailer-mobile-push/sdk/ios
pod spec lint GoMailer.podspec
```

### **Step 3.6: Create Git Repository**
You'll need to push your iOS SDK to a Git repository first:
```bash
git init
git add .
git commit -m "Initial release v1.0.0"
git tag 1.0.0
git remote add origin https://github.com/go-mailer/go-mailer-ios.git
git push origin main
git push origin 1.0.0
```

### **Step 3.7: Publish to CocoaPods**
```bash
pod trunk push GoMailer.podspec
```

### **Step 3.8: Verify Publication**
- Go to [cocoapods.org](https://cocoapods.org)
- Search for "GoMailer"
- Test installation: `pod install` in a test project

---

## 🤖 **4. Android SDK Deployment (Maven Central)**

### **Step 4.1: Create Sonatype Account**
1. Go to [issues.sonatype.org](https://issues.sonatype.org)
2. Create a JIRA account
3. Create a "New Project" ticket for your group ID (com.gomailer)

### **Step 4.2: Set up GPG Signing**
```bash
# Generate GPG key
gpg --gen-key

# List keys to get the key ID
gpg --list-secret-keys --keyid-format LONG

# Upload public key to key server
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

### **Step 4.3: Configure Gradle for Publishing**
Create `gradle.properties` in your home directory (`~/.gradle/gradle.properties`):
```properties
signing.keyId=YOUR_KEY_ID
signing.password=YOUR_GPG_PASSPHRASE
signing.secretKeyRingFile=/Users/yourusername/.gnupg/secring.gpg

ossrhUsername=your-sonatype-username
ossrhPassword=your-sonatype-password
```

### **Step 4.4: Update build.gradle**
Add to `/Users/noguntuberu/app/go-mailer-mobile-push/sdk/android/go-mailer/build.gradle`:

```gradle
apply plugin: 'maven-publish'
apply plugin: 'signing'

android {
    // existing configuration...
    
    publishing {
        singleVariant("release") {
            withSourcesJar()
            withJavadocJar()
        }
    }
}

publishing {
    publications {
        release(MavenPublication) {
            groupId = 'com.gomailer'
            artifactId = 'go-mailer'
            version = '1.0.0'

            afterEvaluate {
                from components.release
            }

            pom {
                name = 'Go Mailer SDK'
                description = 'Go Mailer SDK for Android - Customer engagement messaging'
                url = 'https://github.com/go-mailer/go-mailer-android'
                
                licenses {
                    license {
                        name = 'MIT License'
                        url = 'https://opensource.org/licenses/MIT'
                    }
                }
                
                developers {
                    developer {
                        id = 'gomailer'
                        name = 'Go Mailer Team'
                        email = 'support@gomailer.com'
                    }
                }
                
                scm {
                    connection = 'scm:git:git://github.com/go-mailer/go-mailer-android.git'
                    developerConnection = 'scm:git:ssh://github.com:go-mailer/go-mailer-android.git'
                    url = 'https://github.com/go-mailer/go-mailer-android/tree/main'
                }
            }
        }
    }
    
    repositories {
        maven {
            name = "sonatype"
            url = "https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/"
            credentials {
                username ossrhUsername
                password ossrhPassword
            }
        }
    }
}

signing {
    sign publishing.publications.release
}
```

### **Step 4.5: Build and Publish**
```bash
cd /Users/noguntuberu/app/go-mailer-mobile-push/sdk/android
./gradlew publishToSonatype
```

### **Step 4.6: Release on Sonatype**
1. Go to [s01.oss.sonatype.org](https://s01.oss.sonatype.org)
2. Login with your credentials
3. Go to "Staging Repositories"
4. Find your repository, select it
5. Click "Close" then "Release"

---

## ✅ **5. Post-Deployment Checklist**

### **Verify All Packages**
- [ ] Flutter: `flutter pub deps go_mailer`
- [ ] React Native: `npm info go-mailer`
- [ ] iOS: `pod search GoMailer`
- [ ] Android: Check [search.maven.org](https://search.maven.org) for `com.gomailer:go-mailer`

### **Update Documentation**
- [ ] Update installation instructions in all docs
- [ ] Remove "local development" paths
- [ ] Add package manager installation commands
- [ ] Update version numbers in examples

### **Create Release Notes**
Create a `CHANGELOG.md` with:
```markdown
# Changelog

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Go Mailer SDK
- Cross-platform push notifications (iOS, Android, Flutter, React Native)
- Automatic notification click tracking
- User data management and segmentation
- Production-ready with comprehensive error handling

### Features
- Flutter SDK with native iOS/Android modules
- React Native SDK with TypeScript support
- Native iOS SDK with Swift/CocoaPods
- Native Android SDK with Kotlin/Gradle
- Comprehensive documentation and examples
```

### **Test Installation**
Create test projects and verify:
```bash
# Test Flutter
flutter create test_flutter
cd test_flutter
flutter pub add go_mailer

# Test React Native
npx react-native init TestRN
cd TestRN
npm install go-mailer

# Test iOS
pod init
# Add pod 'GoMailer' to Podfile
pod install

# Test Android
# Add implementation 'com.gomailer:go-mailer:1.0.0' to build.gradle
```

---

## 🚨 **Common Issues & Solutions**

### **Flutter Issues**
- **"Package validation failed"**: Run `flutter pub publish --dry-run` first
- **"Analysis issues"**: Fix all linting errors before publishing

### **React Native Issues**
- **"npm publish failed"**: Ensure you're logged in with `npm whoami`
- **"TypeScript errors"**: Run `npm run build` before publishing

### **iOS Issues**
- **"Podspec validation failed"**: Check all dependencies exist
- **"Git tag not found"**: Ensure you've pushed tags: `git push origin --tags`

### **Android Issues**
- **"GPG signing failed"**: Verify GPG setup with `gpg --list-secret-keys`
- **"Sonatype upload failed"**: Check credentials in `~/.gradle/gradle.properties`

---

## 🎉 **Congratulations!**

Once all SDKs are published, developers can install them with:

```bash
# Flutter
flutter pub add go_mailer

# React Native
npm install go-mailer

# iOS
pod 'GoMailer'

# Android
implementation 'com.gomailer:go-mailer:1.0.0'
```

Your Go Mailer SDKs are now available to developers worldwide! 🌍

---

## 📚 **Next Steps**

1. **Monitor Downloads**: Track usage on package manager dashboards
2. **Community Support**: Respond to issues and questions
3. **Version Updates**: Plan for future releases and bug fixes
4. **Documentation**: Keep improving based on user feedback

## 🆘 **Need Help?**

If you encounter issues during deployment:
1. Check package manager documentation
2. Review error messages carefully
3. Test with dry-run commands first
4. Ask for help in developer communities

**You've got this!** 🚀
