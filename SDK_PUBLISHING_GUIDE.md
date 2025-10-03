# 📦 GoMailer SDK Publishing Guide

## 🎯 **Publishing Status Overview**

This guide covers the publishing process for all GoMailer SDKs across different package managers.

---

## 🚀 **Current Publishing Status**

### **✅ Published SDKs**
- **React Native:** `go-mailer-push-sdk@1.3.1` on npm ✅
- **Flutter:** `go_mailer_push_sdk@1.3.1` - Ready to publish to pub.dev
- **iOS:** `GoMailerPushSDK@1.3.1` - Ready to publish to CocoaPods
- **Android:** `com.gomailer:go-mailer@1.3.1` - Ready to publish to Maven Central

---

## 📋 **Publishing Prerequisites**

### **Required Credentials**
- [ ] **npm:** NPM_TOKEN secret configured
- [ ] **pub.dev:** PUB_CREDENTIALS_JSON_B64 secret configured  
- [ ] **CocoaPods:** Pod trunk account setup
- [ ] **Maven Central:** OSSRH credentials + GPG signing key

### **Version Alignment Check**
All SDKs are now aligned to version `1.3.1`:
- ✅ React Native: `1.3.1`
- ✅ Flutter: `1.3.1`
- ✅ iOS: `1.3.1`
- ✅ Android: `1.3.1`

---

## 🔄 **Automated Publishing Process**

### **GitHub Actions Workflow**
Our automated publishing is configured in `.github/workflows/publish.yml`:

```bash
# Publish all SDKs with version tag
git tag v1.3.1
git push origin v1.3.1

# OR manually trigger workflow
gh workflow run publish.yml --ref main -f version=1.3.1
```

### **What Gets Published Automatically**
1. **Flutter Package** → pub.dev
2. **Android Library** → Maven Central
3. **React Native Package** → npm
4. **Release Notes** → GitHub Releases

---

## 📱 **Platform-Specific Publishing**

### **1. React Native (npm)**

**Package:** `go-mailer-push-sdk`  
**Status:** ✅ Published v1.3.1  
**URL:** https://www.npmjs.com/package/go-mailer-push-sdk

```bash
# Manual publishing (if needed)
cd sdk/react-native
npm login
npm publish --access public
```

**Installation for customers:**
```bash
npm install go-mailer-push-sdk@1.3.1
```

### **2. Flutter (pub.dev)**

**Package:** `go_mailer_push_sdk`  
**Status:** 🔄 Ready to publish  
**URL:** https://pub.dev/packages/go_mailer_push_sdk (after publishing)

```bash
# Manual publishing
cd sdk/flutter
flutter pub publish

# Automated via GitHub Actions
gh workflow run publish.yml -f version=1.3.1
```

**Installation for customers:**
```yaml
dependencies:
  go_mailer_push_sdk: ^1.3.1
```

### **3. iOS (CocoaPods)**

**Package:** `GoMailerPushSDK`  
**Status:** 🔄 Ready to publish  
**URL:** https://cocoapods.org/pods/GoMailerPushSDK (after publishing)

```bash
# Manual publishing
cd sdk/ios
pod trunk push GoMailerPushSDK.podspec

# Validate first
pod lib lint GoMailerPushSDK.podspec --allow-warnings
```

**Installation for customers:**
```ruby
pod 'GoMailerPushSDK', '~> 1.3.1'
```

### **4. Android (Maven Central)**

**Package:** `com.gomailer:go-mailer`  
**Status:** 🔄 Ready to publish  
**URL:** https://central.sonatype.com/artifact/com.gomailer/go-mailer (after publishing)

```bash
# Manual publishing
cd sdk/android/go-mailer
./gradlew publishReleasePublicationToMavenCentralRepository

# Automated via GitHub Actions (preferred)
gh workflow run publish.yml -f version=1.3.1
```

**Installation for customers:**
```gradle
dependencies {
    implementation 'com.gomailer:go-mailer:1.3.1'
}
```

---

## 🔍 **Pre-Publishing Validation**

### **Testing Checklist**
- [ ] All example apps build and run successfully
- [ ] SDKs work with published dependencies
- [ ] Documentation is up-to-date
- [ ] Version numbers are aligned
- [ ] Breaking changes are documented

### **Validation Script**
```bash
# Run comprehensive validation
./scripts/release.sh

# Check version alignment
grep -r "version.*1\.3\.1" sdk/*/
```

---

## 📊 **Post-Publishing Verification**

### **Immediate Checks (Within 1 hour)**
- [ ] **npm:** Package visible at https://www.npmjs.com/package/go-mailer-push-sdk
- [ ] **pub.dev:** Package visible at https://pub.dev/packages/go_mailer_push_sdk
- [ ] **CocoaPods:** Pod searchable via `pod search GoMailerPushSDK`
- [ ] **Maven Central:** Available via Maven Central search

### **Integration Testing (Within 4 hours)**
- [ ] **React Native:** `npm install go-mailer-push-sdk@1.3.1` works
- [ ] **Flutter:** `flutter pub add go_mailer_push_sdk:1.3.1` works
- [ ] **iOS:** `pod install` pulls correct version
- [ ] **Android:** Gradle sync resolves dependency

### **Propagation Testing (Within 24 hours)**
- [ ] CDN propagation complete
- [ ] Package managers worldwide have the update
- [ ] Documentation sites reflect new version
- [ ] Example projects work with published packages

---

## 🚨 **Emergency Publishing Procedures**

### **Critical Bug Fix Publishing**
If a critical bug is found post-release:

1. **Immediate Response:**
   ```bash
   # Create hotfix branch
   git checkout -b hotfix/v1.3.2
   
   # Fix the issue
   # Update version numbers
   # Test thoroughly
   
   # Publish immediately
   git tag v1.3.2
   git push origin v1.3.2
   ```

2. **Communication:**
   - Notify beta customers immediately
   - Update documentation
   - Post in community channels

### **Rollback Procedures**
If a published version needs to be withdrawn:

- **npm:** Cannot delete, publish patch version
- **pub.dev:** Cannot delete, publish patch version  
- **CocoaPods:** Contact CocoaPods team for critical issues
- **Maven Central:** Cannot delete, publish patch version

---

## 📈 **Success Metrics & Monitoring**

### **Download/Installation Tracking**
- **npm:** Monitor via npm analytics
- **pub.dev:** Track via pub.dev package page
- **CocoaPods:** Monitor via CocoaPods metrics
- **Maven Central:** Track via Central analytics

### **Expected Metrics (Week 1)**
- **React Native:** 100+ downloads
- **Flutter:** 50+ downloads
- **iOS:** 25+ pod installs
- **Android:** 50+ Maven downloads

### **Health Monitoring**
- **Error Rates:** < 2% across all platforms
- **Support Tickets:** Monitor for integration issues
- **Community Feedback:** Track GitHub issues and discussions

---

## 🛠️ **Troubleshooting Publishing Issues**

### **Common Publishing Problems**

**npm Publishing:**
```bash
# Authentication issues
npm login
npm whoami

# Version conflicts
npm view go-mailer-push-sdk versions --json
```

**pub.dev Publishing:**
```bash
# Authentication issues
dart pub token add https://pub.dev

# Validation errors
dart pub publish --dry-run
```

**CocoaPods Publishing:**
```bash
# Trunk authentication
pod trunk me

# Spec validation
pod lib lint --allow-warnings
```

**Maven Central Publishing:**
```bash
# GPG setup issues
gpg --list-secret-keys
gpg --keyserver keyserver.ubuntu.com --send-keys [KEY_ID]
```

### **Support Contacts**
- **npm Issues:** https://www.npmjs.com/support
- **pub.dev Issues:** https://github.com/dart-lang/pub-dev/issues
- **CocoaPods Issues:** https://github.com/CocoaPods/CocoaPods/issues
- **Maven Central Issues:** https://central.sonatype.org/pages/help.html

---

## 🎯 **Beta Customer Communication**

### **Pre-Publishing Announcement**
```markdown
🚀 **GoMailer SDK v1.3.1 Publishing Update**

We're preparing to publish all SDKs to their respective package managers:

📦 **Timeline:**
- React Native: Already live on npm
- Flutter: Publishing to pub.dev within 24 hours
- iOS: Publishing to CocoaPods within 24 hours  
- Android: Publishing to Maven Central within 24 hours

🔧 **For Beta Customers:**
You can continue using local/git references during beta testing.
We'll provide migration guides when moving to published packages.

📞 **Questions?** Reach out in #gomailer-beta
```

### **Post-Publishing Announcement**
```markdown
🎉 **GoMailer SDK v1.3.1 Now Live!**

All SDKs are now published and available:

✅ **React Native:** `npm install go-mailer-push-sdk@1.3.1`
✅ **Flutter:** `flutter pub add go_mailer_push_sdk:1.3.1`
✅ **iOS:** `pod 'GoMailerPushSDK', '~> 1.3.1'`
✅ **Android:** `implementation 'com.gomailer:go-mailer:1.3.1'`

📚 **Updated Documentation:** See BETA_ONBOARDING.md for integration guides
🧪 **Next Steps:** Continue with your platform testing using published packages
```

---

## 🚀 **Ready to Publish!**

**All prerequisites met:**
- ✅ Version alignment complete
- ✅ Testing completed across all platforms
- ✅ Documentation updated
- ✅ CI/CD pipeline ready
- ✅ Support infrastructure in place

**Execute publishing:**
```bash
# Trigger automated publishing for all platforms
git tag v1.3.1
git push origin v1.3.1

# Monitor publishing progress
gh run list --workflow=publish.yml
```

**Post-publishing tasks:**
1. Verify all packages are live
2. Update beta customer communication
3. Begin beta customer onboarding
4. Monitor for any immediate issues

🎯 **Ready for beta customers within 24 hours of publishing!**