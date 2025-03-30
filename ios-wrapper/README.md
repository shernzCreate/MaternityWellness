# Maternal Wellness iOS Wrapper

This directory contains the iOS wrapper that allows the Maternal Wellness web application to be packaged as a native iOS app for distribution through the App Store.

## Project Structure

- `MaternityApp/` - Contains the iOS application source files
  - `AppDelegate.swift` - Main entry point for the iOS application
  - `ViewController.swift` - Implements a WebView that loads the web application
  - `Info.plist` - Configuration settings for the iOS app
  - `LaunchScreen.storyboard` - Launch screen displayed while the app is starting

- `MaternityApp.xcodeproj/` - Xcode project files
  - `project.pbxproj` - Xcode project configuration file

## Opening in Xcode

1. Clone or download this repository to your Mac
2. Open Xcode
3. Choose "Open a Project or File"
4. Navigate to the `ios-wrapper` directory and select the `MaternityApp.xcodeproj` file
5. Click "Open"

## Development Workflow

The iOS wrapper loads the web application from a server. During development, you can:

1. Run the web application locally using `npm run dev`
2. Edit the `ViewController.swift` file to point to your local server (already configured for localhost:5000)
3. Build and run the iOS app in the simulator

For production deployment:

1. Build the web application for production
2. Update the URL in `ViewController.swift` to point to the hosted version of your web app or include the built web app in the iOS project's assets
3. Build the iOS app for distribution

## Communication Between Web and Native

The iOS wrapper includes a JavaScript bridge that allows the web application to communicate with native iOS features. The web app can send messages to the native layer using the following pattern:

```javascript
// From web app JavaScript
window.webkit.messageHandlers.nativeBridge.postMessage({
  action: 'notification',
  title: 'Hello',
  body: 'This is a notification from the web app'
});
```

Supported actions:
- `notification`: Display a native alert dialog
- `share`: Open the iOS share sheet
- `openSettings`: Open the app settings

## Customization

To customize the app for your specific needs:

1. Update bundle identifier and app details in Xcode
2. Add app icons and splash screens
3. Modify `Info.plist` for additional permissions or features
4. Add Swift code for any native functionality you want to expose to the web app

## Requirements

- Xcode 14.0 or later
- iOS 15.0+ deployment target
- Swift 5.0