import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            AssessmentView()
                .tabItem {
                    Label("Assessment", systemImage: "list.clipboard.fill")
                }
            
            ResourcesView()
                .tabItem {
                    Label("Resources", systemImage: "book.fill")
                }
        }
        .accentColor(Color("AccentColor"))
    }
}