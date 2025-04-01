import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var moodViewModel = MoodViewModel()
    @StateObject private var assessmentViewModel = AssessmentViewModel()
    @StateObject private var resourceViewModel = ResourceViewModel()
    
    var body: some View {
        TabView {
            // Home Tab
            HomeView()
                .environmentObject(moodViewModel)
                .environmentObject(assessmentViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Assessment Tab
            AssessmentView()
                .environmentObject(assessmentViewModel)
                .tabItem {
                    Label("Assessment", systemImage: "list.bullet.clipboard")
                }
            
            // Resources Tab
            ResourcesView()
                .environmentObject(resourceViewModel)
                .tabItem {
                    Label("Resources", systemImage: "book.fill")
                }
            
            // Support Tab (Placeholder for future development)
            SupportView()
                .tabItem {
                    Label("Support", systemImage: "message.fill")
                }
        }
        .accentColor(Color("AccentColor"))
        .onAppear {
            // Set the tab bar appearance
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    }
}

// Placeholder for Support View
struct SupportView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "message.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("AccentColor"))
                    .padding()
                
                Text("Support Features Coming Soon")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("We're working on bringing you direct support features including chat with healthcare professionals and community forums.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Divider()
                    .padding()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Need immediate help?")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(Color("AccentColor"))
                        
                        VStack(alignment: .leading) {
                            Text("National Care Hotline")
                                .fontWeight(.medium)
                            Text("1800-202-6868")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(Color("AccentColor"))
                        
                        VStack(alignment: .leading) {
                            Text("Mental Health Helpline")
                                .fontWeight(.medium)
                            Text("6389 2222 (24 hours)")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(Color("AccentColor"))
                        
                        VStack(alignment: .leading) {
                            Text("Samaritans of Singapore (SOS)")
                                .fontWeight(.medium)
                            Text("1800-221-4444 (24 hours)")
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Support")
        }
    }
}