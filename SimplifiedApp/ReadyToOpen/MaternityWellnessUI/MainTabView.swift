import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Progress Tab
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .tag(1)
            
            // Mood Tracker Tab
            MoodTrackerView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Mood")
                }
                .tag(2)
            
            // Assessment Tab
            AssessmentView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Assessment")
                }
                .tag(3)
            
            // Resources Tab
            ResourcesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Resources")
                }
                .tag(4)
            
            // Profile/Settings Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(5)
        }
        .accentColor(ColorTheme.primaryPink) // Use the theme accent color for the selected tab
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(isLoggedIn: .constant(true))
    }
}
