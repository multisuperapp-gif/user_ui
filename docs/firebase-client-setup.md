# Firebase Client Setup

This app is now wired for real Firebase Cloud Messaging on both Android and iOS.

## Android

Place the Firebase Android client file here:

- `/Users/rajnishsingh/development/msa_user_app/android/app/google-services.json`

Important:

- The Firebase Android app package name must match the app `applicationId` in:
  - `/Users/rajnishsingh/development/msa_user_app/android/app/build.gradle.kts`
- Current value:
  - `com.example.msa_user_app`

## iOS

Place the Firebase iOS client file here:

- `/Users/rajnishsingh/development/msa_user_app/ios/Runner/GoogleService-Info.plist`

Important:

- The Firebase iOS bundle id must match the Runner bundle id in Xcode.
- Firebase is initialized in:
  - `/Users/rajnishsingh/development/msa_user_app/ios/Runner/AppDelegate.swift`

## What is already done

- Android Google Services Gradle plugin added
- Android 13 notification permission added
- iOS minimum platform set to `13.0`
- iOS Firebase app initialization added
- Flutter app already registers the push token when Firebase config exists

## Still required outside code

- Add the real Firebase client files above
- In Apple Developer / Xcode, enable Push Notifications capability for the app target
- Upload APNs key/certificate in Firebase for iOS push delivery
