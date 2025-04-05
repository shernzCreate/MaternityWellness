# Maternity Wellness App for Singapore

A comprehensive mobile application for postpartum depression management, designed to support new mothers in Singapore. This simplified UI version is focused on being easily importable in Xcode while maintaining the core functionality of the application.

## Features

- **Authentication**: Simple login and registration for users
- **Assessments**: Standardized screening tools (EPDS and PHQ-9) for early detection
- **Mood Tracking**: Daily mood monitoring with customizable notes
- **Resources**: Singapore-specific educational content with information from KK Hospital, NUH, and MOH

## Technical Details

- **Built with**: SwiftUI
- **iOS Target**: iOS 17.0+
- **Architecture**: Simple view-based structure for easy extensibility
- **UI Design**: Native iOS components with simple, intuitive interfaces

## Importing to Xcode

1. Clone this repository
2. Open Xcode and select "Create a new Xcode project"
3. Choose "iOS" > "App" template
4. Configure your project settings:
   - Product Name: MaternityWellnessUI
   - Interface: SwiftUI
   - Lifecycle: SwiftUI App
   - Language: Swift
   - Deployment Target: iOS 17.0
5. Create the project
6. Replace the default ContentView.swift with the files from SimplifiedApp/MaternityWellnessUI
7. Add all Swift files to your project

## Development Roadmap

1. ✅ UI Implementation
2. 🔲 Local data persistence
3. 🔲 Cloud synchronization
4. 🔲 Analytics
5. 🔲 Notifications and reminders
6. 🔲 Community features

## Simplified Version Benefits

- Easy to import into Xcode without complex dependencies
- Focus on UI components - allows for gradual backend implementation
- Prioritizes the core functionality first
- Designed with production-ready UI patterns
