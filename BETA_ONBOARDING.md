# 🚀 GoMailer SDK Beta Program - Onboarding Guide

Welcome to the GoMailer SDK Beta Program! This guide will help you integrate our push notification SDKs across Flutter, React Native, iOS, and Android platforms.

## 📋 **Beta Program Overview**

**Program Duration:** 2-3 weeks  
**Support Level:** Direct Slack/Email support with engineering team  
**Expected Commitment:** 5-10 hours integration + weekly feedback sessions  

## 🎯 **What We're Testing**

### **Core Features:**
- ✅ **Multi-Platform SDK Integration** (Flutter, React Native, iOS Native, Android Native)
- ✅ **Dynamic Environment Switching** (Production, Staging, Development)
- ✅ **Push Notification Delivery** across all platforms
- ✅ **Notification Click Tracking** and analytics
- ✅ **User Registration & Device Token Management**

### **Beta Focus Areas:**
- 🔍 **Integration Experience** - How easy is SDK setup?
- 🔍 **Documentation Quality** - Are our guides clear and complete?
- 🔍 **Cross-Platform Consistency** - Do all platforms behave similarly?
- 🔍 **Error Handling** - How well do we handle edge cases?
- 🔍 **Performance Impact** - App size and runtime performance

---

## 📱 **Platform Integration Guides**

### **1. React Native Integration**

```bash
# Install SDK
npm install go-mailer-push-sdk@1.3.1

# iOS additional setup
cd ios && pod install
```

**Integration:**
```javascript
import GoMailer from 'go-mailer-push-sdk';

// Initialize (typically in App.js)
await GoMailer.configure({
  apiKey: 'YOUR_API_KEY',
  environment: 'production' // or 'staging', 'development'
});

// Register user
await GoMailer.setUser('user@example.com');

// Request notification permissions
await GoMailer.requestNotificationPermissions();
```

### **2. Flutter Integration**

```yaml
# pubspec.yaml
dependencies:
  go_mailer_push_sdk: ^1.3.1
```

**Integration:**
```dart
import 'package:go_mailer_push_sdk/go_mailer_push_sdk.dart';

// Initialize (typically in main.dart)
await GoMailerPushSdk.configure(
  apiKey: 'YOUR_API_KEY',
  environment: GoMailerEnvironment.production,
);

// Register user
await GoMailerPushSdk.setUser('user@example.com');

// Request permissions
await GoMailerPushSdk.requestNotificationPermissions();
```

### **3. iOS Native Integration**

```ruby
# Podfile
pod 'GoMailerPushSDK', '~> 1.3.1'
```

**Integration:**
```swift
import GoMailerPushSDK

// Initialize (in AppDelegate)
GoMailerPushSDK.configure(
    apiKey: "YOUR_GOMAILER_API_KEY", // Contact support for beta credentials
    environment: .production
)

// Register user
GoMailerPushSDK.setUser(email: "user@example.com")

// Request permissions
GoMailerPushSDK.requestNotificationPermissions()
```

### **4. Android Native Integration**

```gradle
// app/build.gradle
dependencies {
    implementation 'com.github.go-mailer-ltd:go-mailer-push-sdk:1.3.1'
}
```

**Integration:**
```kotlin
import com.gomailer.GoMailerPushSDK

// Initialize (in Application or MainActivity)
GoMailerPushSDK.configure(
    this,
    apiKey = "YOUR_GOMAILER_API_KEY", // Contact support for beta credentials
    environment = GoMailerEnvironment.PRODUCTION
)

// Register user
GoMailerPushSDK.setUser("user@example.com")

// Request permissions (Android 13+)
GoMailerPushSDK.requestNotificationPermissions(this)
```

---

## 🔑 **Beta API Keys**

| Environment | API Key | Use Case |
|-------------|---------|----------|
| **Production** | `R28tTWFpbGVyLTQ5NTExMjgwOTU1OC41NDI4LTQw` | Final testing, real notifications |
| **Staging** | `R2FtYm8tMTU2Mjc3Njc2Mjg2My43ODI1LTI=` | Integration testing |
| **Development** | `R2FtYm8tODAwNDQwMDcwNzc0LjI1NjUtMjcw` | Early development |

**⚠️ Important:** These are real API keys. Please treat them securely and don't commit them to public repositories.

---

## 🧪 **Testing Checklist**

### **Week 1: Basic Integration**
- [ ] **SDK Installation** - Successfully add SDK to your project
- [ ] **Initialization** - Configure with provided API key
- [ ] **Environment Switching** - Test switching between environments
- [ ] **User Registration** - Register test users successfully
- [ ] **Permission Requests** - Request and receive notification permissions

### **Week 2: Advanced Testing**
- [ ] **Push Notifications** - Receive notifications when app is closed/backgrounded
- [ ] **Notification Clicks** - Tap notifications and verify click tracking
- [ ] **Cross-Platform** - Test same features across multiple platforms
- [ ] **Error Scenarios** - Test with invalid emails, network issues, etc.
- [ ] **Performance** - Monitor app size increase and runtime performance

### **Week 3: Production Readiness**
- [ ] **Production Environment** - Test with production API keys
- [ ] **Real User Flows** - Integrate into your actual app workflows
- [ ] **Edge Cases** - Test device restarts, app updates, etc.
- [ ] **Documentation Review** - Provide feedback on our guides
- [ ] **Final Feedback** - Complete comprehensive feedback survey

---

## 📊 **Feedback Collection**

### **Daily Feedback (5 minutes):**
- Quick Slack updates in `#gomailer-beta` channel
- Any blockers or issues encountered
- What worked well that day

### **Weekly Feedback (30 minutes):**
- **Monday:** Planning session with engineering team
- **Wednesday:** Mid-week progress check
- **Friday:** Week wrap-up and weekend planning

### **Final Feedback (60 minutes):**
- Comprehensive integration experience review
- Documentation quality assessment
- Feature request priorities
- Public release readiness assessment

---

## 🆘 **Support Channels**

### **Immediate Support:**
- **Slack:** `#gomailer-beta` channel
- **Email:** `beta-support@go-mailer.com`
- **Emergency:** Direct message to engineering lead

### **Response Times:**
- **Critical Issues:** < 4 hours (business days)
- **Integration Questions:** < 8 hours (business days)
- **Feature Requests:** Weekly review cycle

### **Documentation:**
- **API Reference:** https://docs.go-mailer.com/api
- **Integration Guides:** Available in `/docs` folder
- **Troubleshooting:** https://docs.go-mailer.com/troubleshooting

---

## 🎉 **Success Metrics**

We consider the beta successful when:

### **Technical Metrics:**
- [ ] **Integration Time:** <2 hours per platform for experienced developers
- [ ] **Error Rate:** <2% SDK initialization failures
- [ ] **Performance:** <5MB app size increase, <100ms initialization time
- [ ] **Cross-Platform Consistency:** >95% feature parity

### **Experience Metrics:**
- [ ] **Documentation Quality:** >4/5 average rating
- [ ] **Developer Satisfaction:** >4/5 average rating
- [ ] **Support Responsiveness:** >4/5 average rating
- [ ] **Recommendation Score:** >8/10 NPS

---

## 🚀 **Next Steps**

1. **Join Beta Slack Channel:** We'll send you an invite
2. **Choose Your Platform:** Start with your team's primary platform
3. **Follow Integration Guide:** Use the appropriate section above
4. **Daily Check-ins:** Share progress and blockers
5. **Weekly Reviews:** Participate in feedback sessions

**Ready to start? Let's make mobile push notifications better together! 🎯**

---

## 📞 **Contact Information**

**Engineering Team:**
- **Lead Engineer:** Available in Slack `#gomailer-beta`
- **Documentation:** Available for real-time updates
- **Product Manager:** Weekly strategy discussions

**Beta Program Manager:**
- **Email:** `beta-program@go-mailer.com`
- **Slack:** `@beta-manager`
- **Calendly:** Schedule 1:1 sessions as needed

---

*This is a living document. We'll update it based on your feedback throughout the beta program.*