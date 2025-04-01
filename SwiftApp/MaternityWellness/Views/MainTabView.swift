import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // Home Tab
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            // Assessment Tab
            NavigationView {
                AssessmentView()
            }
            .tabItem {
                Label("Assessment", systemImage: "checklist")
            }
            
            // Resources Tab
            NavigationView {
                ResourcesView()
            }
            .tabItem {
                Label("Resources", systemImage: "book")
            }
        }
        .accentColor(Color("AccentColor"))
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        authViewModel.currentUser = User(username: "testuser", fullName: "Test User", email: "test@example.com")
        
        return MainTabView()
            .environmentObject(authViewModel)
    }
}