import SwiftUI

struct AuthView: View {
    @State private var showLogin = true
    
    var body: some View {
        VStack {
            // App logo/header
            VStack {
                Text("Maternity Wellness")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Text("Support for your journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 50)
            
            // Toggle between login and signup
            Picker("Mode", selection: $showLogin) {
                Text("Login").tag(true)
                Text("Sign Up").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            
            if showLogin {
                LoginView()
                    .transition(.opacity)
            } else {
                SignupView()
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .animation(.default, value: showLogin)
        .background(Color(.systemBackground))
    }
}