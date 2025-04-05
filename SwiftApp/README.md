# Maternity Wellness iOS App

A comprehensive iOS application designed to support new mothers in Singapore with postpartum depression detection and management.

## Overview

This app provides:

1. **Self-Assessment Tools**: Standardized questionnaires (EPDS and PHQ-9) to identify early warning signs
2. **Mood Tracking**: Daily mood monitoring
3. **Educational Resources**: Singapore-specific information about postpartum depression
4. **Support Networks**: Connection to mental health professionals and local support services

## Project Structure

The app is built as a native iOS application using SwiftUI and follows the MVVM (Model-View-ViewModel) architecture.

## How to Open the Project in Xcode

### Option 1: Create a New Xcode Project

1. **Open Xcode** and select "Create a new Xcode project"
2. Choose **iOS** as the platform and **App** as the template
3. Enter "MaternityWellness" as the Product Name
4. Set Organization Identifier (e.g., "com.example")
5. Choose **SwiftUI** for the Interface and **Swift** for the language
6. Set iOS Deployment Target to **iOS 17.0** (the latest stable release)
7. Make sure "Use Core Data" is unchecked
8. Select a location to save the project
9. **Copy the files from this repository's** `SwiftApp/MaternityWellness/MaternityWellness` folder into your new Xcode project
10. **Create folders** in your project matching the structure in the repository (Models, Views, ViewModels, etc.)
11. Move the Swift files into their appropriate folders
12. Ensure the color assets in Assets.xcassets are properly set up

### Option 2: Use the Setup Script (Advanced)

1. Open Terminal and navigate to the `SwiftApp/MaternityWellness` directory
2. Run `chmod +x setup_xcode_project.sh` to make the script executable
3. Run `./setup_xcode_project.sh` to create a basic Xcode project structure
4. Open Xcode and create a new project as in Option 1
5. Move your new files into the generated structure

## File Organization

```
MaternityWellness/
├── MaternityWellnessApp.swift (App entry point)
├── ContentView.swift (Main content container)
├── Models/
│   ├── User.swift (User authentication model)
│   ├── Assessment.swift (EPDS and PHQ-9 models)
│   └── ... (Other models)
├── ViewModels/
│   └── AuthViewModel.swift (Authentication logic)
├── Views/
│   ├── MainTabView.swift (Tab navigation)
│   ├── Auth/
│   │   ├── AuthView.swift (Auth container)
│   │   ├── LoginView.swift
│   │   └── SignupView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── MoodTrackerView.swift
│   ├── Assessment/
│   │   ├── AssessmentView.swift
│   │   └── QuestionnaireView.swift
│   └── Resources/
│       └── ResourcesView.swift
└── Assets.xcassets/
    ├── AccentColor.colorset/
    ├── GreatMood.colorset/
    ├── GoodMood.colorset/
    ├── OkayMood.colorset/
    ├── SadMood.colorset/
    └── TerribleMood.colorset/
```

## Development Notes

- The app is designed primarily for Singapore users with local hospital resources and hotlines
- Authentication is simulated for demonstration purposes and would be replaced with a real system
- All questionnaires are based on medically validated tools (EPDS and PHQ-9)

## Requirements

- iOS 17.0+ (compatible with iPhone and iPad)
- Xcode 15.0+
- Swift 5.9+

## Next Steps

1. Implement backend connectivity for user authentication
2. Add local data persistence for assessments and mood tracking
3. Enhance UI with more detailed resources specific to Singapore
4. Implement push notifications for mood tracking reminders
5. Add community support features
