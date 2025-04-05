# Maternity Wellness App

A comprehensive iOS application supporting postpartum depression management for new mothers in Singapore, providing personalized mental health resources and support.

## Features

- Self-assessment tools (EPDS and PHQ-9 questionnaires)
- Mood tracking
- Singapore-specific educational resources
- Support networks and helpline information

## Opening in Xcode

### Method 1: Create a New Xcode Project

1. Open Xcode and create a new iOS app project
2. Name it "MaternityWellness"
3. Select SwiftUI for the interface
4. Choose Swift as the programming language
5. Save it in a convenient location
6. Copy all Swift files from the repository's SwiftApp/MaternityWellness/MaternityWellness/ folder into your new project
7. Organize the files into the appropriate folders (Models, Views, ViewModels)
8. Create the necessary color assets in Assets.xcassets:
   - AccentColor
   - GreatMood
   - GoodMood
   - OkayMood
   - SadMood
   - TerribleMood

### Method 2: Using the Setup Script

1. Navigate to the SwiftApp/MaternityWellness directory in the terminal
2. Run `chmod +x setup_xcode_project.sh` to make the script executable
3. Run `./setup_xcode_project.sh` to create a basic Xcode project structure
4. Open the generated .xcodeproj file
5. Follow the instructions at the end of the script to complete the setup

## Project Structure

```
MaternityWellness/
├── MaternityWellnessApp.swift (App entry point)
├── ContentView.swift (Main content container)
├── Models/
│   ├── User.swift
│   ├── Mood.swift
│   ├── Assessment.swift
│   └── Resource.swift
├── ViewModels/
│   └── AuthViewModel.swift
└── Views/
    ├── MainTabView.swift
    ├── Auth/
    │   ├── AuthView.swift
    │   ├── LoginView.swift
    │   └── SignupView.swift
    ├── Home/
    │   ├── HomeView.swift
    │   └── MoodTrackerView.swift
    ├── Assessment/
    │   ├── AssessmentView.swift
    │   └── QuestionnaireView.swift
    └── Resources/
        └── ResourcesView.swift
```

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Notes

- This app is designed primarily for mothers in Singapore
- Resources include information from Singapore healthcare providers (KK Hospital, NUH, MOH)
- The app uses mock data and simulated authentication for demonstration purposes
- In a production environment, these would be replaced with real API services