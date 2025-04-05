import SwiftUI

struct MainTabView: View {
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
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
