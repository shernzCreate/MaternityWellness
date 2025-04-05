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
            
            // Mood Tracker Tab
            MoodTrackerView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Mood")
                }
                .tag(1)
            
            // Assessment Tab
            AssessmentView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Assessment")
                }
                .tag(2)
            
            // Resources Tab
            ResourcesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Resources")
                }
                .tag(3)
            
            // Profile/Settings Tab
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(ColorTheme.primaryPink) // Use the theme accent color for the selected tab
    }
}

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Profile Header
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(ColorTheme.primaryPink)
                            .padding(.bottom, 10)
                        
                        Text("User Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textGray)
                        
                        Text("example@email.com")
                            .foregroundColor(ColorTheme.textGray)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        Text("Log Out")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(ColorTheme.buttonGradient)
                            .cornerRadius(15)
                            .shadow(color: ColorTheme.primaryPink.opacity(0.4), radius: 5, x: 0, y: 3)
                    }
                    .padding(.bottom, 50)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(isLoggedIn: .constant(true))
    }
}
