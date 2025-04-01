import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showLogin = true
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side - Auth form
                VStack {
                    // Logo and App Name
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("AccentColor"))
                        
                        Text("Maternity Wellness")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Support for your journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 30)
                    
                    // Toggle between Login and Sign Up
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showLogin = true
                            }
                        }) {
                            Text("Login")
                                .fontWeight(showLogin ? .bold : .regular)
                                .foregroundColor(showLogin ? Color("AccentColor") : .gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showLogin = false
                            }
                        }) {
                            Text("Sign Up")
                                .fontWeight(showLogin ? .regular : .bold)
                                .foregroundColor(showLogin ? .gray : Color("AccentColor"))
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    // Horizontal line with indicator
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 3)
                        
                        Rectangle()
                            .fill(Color("AccentColor"))
                            .frame(width: geometry.size.width * 0.3, height: 3)
                            .offset(x: showLogin ? 0 : geometry.size.width * 0.4)
                    }
                    .padding(.bottom, 20)
                    
                    // Auth forms
                    if showLogin {
                        LoginView()
                            .transition(.opacity)
                    } else {
                        SignupView()
                            .transition(.opacity)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: geometry.size.width * (geometry.size.width > 768 ? 0.5 : 1))
                
                // Right side - Info section (only on large screens)
                if geometry.size.width > 768 {
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Supporting mothers through postpartum wellness")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                FeatureRow(icon: "clipboard.fill", title: "Self-Assessment Tools", description: "Track your mental wellness with validated questionnaires")
                                
                                FeatureRow(icon: "book.fill", title: "Educational Resources", description: "Access Singapore-specific resources from trusted healthcare providers")
                                
                                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Mood Tracking", description: "Monitor your emotional wellbeing day by day")
                                
                                FeatureRow(icon: "person.2.fill", title: "Support Networks", description: "Connect with professionals and peers")
                            }
                        }
                        .padding(30)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AccentColor"), Color("AccentColor").opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .ignoresSafeArea(edges: geometry.size.width > 768 ? .all : [])
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}