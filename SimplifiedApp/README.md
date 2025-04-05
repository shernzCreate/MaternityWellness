# Maternity Wellness UI - Simplified App

This is a simplified version of the Maternity Wellness application focusing on the UI components for easy import into Xcode. The app targets mothers in Singapore, providing support for postpartum depression management through assessment tools, educational resources, and a simple mood tracking feature.

## Key Features

- **Authentication**: Simple login and registration interface
- **Mood Tracking**: Track daily mood with emoji-based UI and optional notes
- **Assessments**: Two standardized questionnaires (EPDS and PHQ-9) with detailed results and interpretations
- **Resources**: Singapore-specific educational materials about postpartum depression from trusted sources like KK Hospital, NUH, and MOH

## Files Structure

- `MaternityWellnessApp.swift` - Main app entry point
- `ContentView.swift` - Container view to handle authentication state
- `LoginView.swift` - Authentication screens with login and registration
- `MainTabView.swift` - Tab navigation for main app features
- `HomeView.swift` - Main dashboard with mood tracking and quick access to features
- `MoodTrackerView.swift` - Interface for updating daily mood
- `AssessmentView.swift` - Access to mental health questionnaires
- `QuestionnaireView.swift` - Standardized questionnaires with scoring (EPDS and PHQ-9)
- `ResourcesView.swift` - Educational materials and support resources

## Development Notes

This is a UI-only implementation meant to be:
1. Easy to import into Xcode
2. A foundation for adding backend functionality gradually
3. Focused on the core UI flows without complex data management

All assessment content (questions, scoring, interpretation) is based on established medical standards:
- Edinburgh Postnatal Depression Scale (EPDS) 
- Patient Health Questionnaire (PHQ-9)

## How to Use

1. Import this folder into an Xcode project
2. The app can be run as-is to test UI flows
3. Gradually implement real data management and networking as needed

## Next Steps for Development

- Implement Core Data for local storage
- Add secure authentication
- Implement cloud synchronization
- Add notifications and reminders
- Build community support features
