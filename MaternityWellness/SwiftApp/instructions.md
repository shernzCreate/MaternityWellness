# How to Open the Xcode Project

This repository contains a Swift/iOS app for maternal wellness. Here's how to open and work with it in Xcode:

## Option 1: Create a New Xcode Project

1. **Open Xcode** and select "Create a new Xcode project"
2. Choose **iOS** as the platform and **App** as the template
3. Enter "MaternityWellness" as the Product Name
4. Set Organization Identifier (e.g., "com.example")
5. Choose **SwiftUI** for the Interface and **Swift** for the language
6. Make sure "Use Core Data" is unchecked
7. Select a location to save the project
8. **Copy the files from this repository's** `SwiftApp/MaternityWellness/MaternityWellness` folder into your new Xcode project
9. **Create folders** in your project matching the structure in the repository (Models, Views, ViewModels, etc.)
10. Move the Swift files into their appropriate folders
11. Create the necessary color assets in Assets.xcassets:
    - AccentColor (teal/blue)
    - GreatMood (bright green)
    - GoodMood (light green)
    - OkayMood (yellow)
    - SadMood (orange)
    - TerribleMood (red)

## Option 2: Use the Setup Script (for Advanced Users)

1. Open Terminal and navigate to the `SwiftApp/MaternityWellness` directory
2. Run `chmod +x setup_xcode_project.sh` to make the script executable
3. Run `./setup_xcode_project.sh` to create a basic Xcode project structure
4. Open Xcode and create a new project as in Option 1, but instead of steps 7-11, simply move your new files into the generated structure

## Important Notes

1. **iOS Deployment Target**: Set to iOS 16.0 for broader compatibility (avoid using iOS 18 beta)
2. **Development Team**: You'll need to set up your Apple Developer account in Xcode's signing settings
3. **File Structure**: Ensure you have all required folders:
   - Models/
   - ViewModels/
   - Views/
     - Auth/
     - Home/
     - Assessment/
     - Resources/
4. **Assets**: Create the color assets as mentioned above

## Running the App

After setting up your project:

1. Select a simulator (iPhone 14 Pro or similar recommended)
2. Press the Run button (▶️) in Xcode
3. The app should launch in the simulator

## Troubleshooting

- If you see errors about missing files, make sure all Swift files from the repository are properly copied over
- For authorization issues, check your Apple Developer account setup and signing settings
- For SwiftUI preview errors, make sure you're using a compatible Xcode version (Xcode 14 or later)

## Next Steps for Development

1. Complete the implementation of any missing features
2. Add real backend connectivity replacing the simulated authentication
3. Enhance the UI with more Singapore-specific content
4. Test on actual devices
5. Prepare for App Store submission