# GoMailer React Native Example

This example app demonstrates how to integrate the local `go-mailer-push-sdk` React Native package.

## Features
- Initialize SDK with API key & environment
- Set user (email)
- Register for push notifications
- Display device token (if SDK exposes a getter)
- Simulate notification click tracking

## Setup

1. Install dependencies:
```bash
cd examples/react-native-example
npm install
```

2. Link / build native modules (React Native autolinking handles the local dependency). Ensure the SDK path: `"go-mailer-push-sdk": "file:../../sdk/react-native"`.

3. Android Firebase (FCM): add your `google-services.json` to `android/app/` after you scaffold the native folders (see below).
4. iOS Firebase: add `GoogleService-Info.plist` to `ios/` main app target directory and run `cd ios && pod install`.

## Scaffolding Native Projects
This minimal example does not include the full `android/` & `ios/` directories that `react-native init` would generate. Run:
```bash
npx react-native init tempScaffold --version 0.80.0 --package-name com.gomailer.rnexample
```
Then copy the generated `android/` and `ios/` folders into `examples/react-native-example/` (skip existing JS files).

After copying, adjust `android/settings.gradle` / `settings.gradle.kts` to include the local module if necessary (autolink usually handles it).

## Run Android
```bash
npm run android
```

## Run iOS
```bash
npm run ios
```

## Environment Switching
Use the buttons inside the app (Production / Staging / Development) and enter your API key.

## Notes
- If `GoMailer.getDeviceToken()` is not yet implemented for React Native, the token box may stay empty.
- Update the component once the SDK exposes an event stream for push/analytics events.

## Cleanup
To reset logs, reload the app (Metro bundler: press `r` in the terminal or use the in-app developer menu).

## License
MIT
