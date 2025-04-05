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
        .onAppear {
            // Set minimum tab bar iOS 17 styling if available
            if #available(iOS 17.0, *) {
                // Use iOS 17 tab bar styling
                print("Using iOS 17 tab bar styling")
            }
        }
    }
}
