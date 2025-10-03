# 🔒 Firebase Configuration Setup

## ⚠️ **SECURITY NOTICE**

This repository uses **template files** for Firebase configuration. You **MUST** create your own Firebase project and configuration files.

### **Required Steps:**

#### **1. Create Firebase Project**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing project
3. Enable **Cloud Messaging (FCM)** service

#### **2. Android Configuration**
1. In Firebase Console → Project Settings → Add App → Android
2. Use package name: `com.gomailer.androidexample` (or your app's package)
3. Download `google-services.json`
4. **Copy** `google-services.template.json` to `google-services.json`
5. **Replace** template values with your Firebase configuration

#### **3. iOS Configuration**
1. In Firebase Console → Project Settings → Add App → iOS
2. Use bundle ID: `com.gomailer.example.ios` (or your app's bundle ID)
3. Download `GoogleService-Info.plist` 
4. **Copy** `GoogleService-Info.template.plist` to `GoogleService-Info.plist`
5. **Replace** template values with your Firebase configuration

### **Template Values to Replace:**

```json
// In google-services.json:
"YOUR_PROJECT_NUMBER"     → Your Firebase project number
"YOUR_PROJECT_ID"         → Your Firebase project ID  
"YOUR_APP_ID"            → Your Android app ID
"YOUR_ANDROID_API_KEY_HERE" → Your Android API key
```

```xml
<!-- In GoogleService-Info.plist: -->
YOUR_IOS_API_KEY_HERE    → Your iOS API key
YOUR_PROJECT_NUMBER      → Your Firebase project number
YOUR_PROJECT_ID          → Your Firebase project ID
YOUR_IOS_APP_ID         → Your iOS app ID
```

### **🚨 NEVER COMMIT REAL CREDENTIALS**

- Real `google-services.json` and `GoogleService-Info.plist` files are in `.gitignore`
- Only commit `.template` versions
- Keep your Firebase credentials secure and private

### **Testing the Setup**

After configuration:
1. Build and run the example app
2. Check for Firebase initialization logs
3. Test push notification registration
4. Verify device token generation

---

**📖 For detailed setup instructions, see the main [README.md](../../README.md)**