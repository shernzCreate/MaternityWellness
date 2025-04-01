import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingLogin = true
    
    var body: some View {
        ZStack {
            // Background
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack {
                // Logo and Header
                VStack(spacing: 20) {
                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("AccentColor"))
                    
                    Text("Maternity Wellness")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("Support for your postpartum journey")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Segmented control for login/signup
                Picker("Authentication Mode", selection: $isShowingLogin) {
                    Text("Login").tag(true)
                    Text("Sign Up").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 30)
                
                // Form container
                ZStack {
                    if isShowingLogin {
                        LoginView()
                            .transition(.opacity)
                    } else {
                        SignupView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: isShowingLogin)
                .padding(.top, 20)
                
                Spacer()
                
                // Footer text
                VStack(spacing: 10) {
                    Text("Designed for new mothers in Singapore")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .alert(item: alertItem) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var alertItem: AlertItem? {
        if let errorMessage = authViewModel.errorMessage {
            return AlertItem(
                title: "Error",
                message: errorMessage
            )
        }
        return nil
    }
}

// Helper struct for alerts
struct AlertItem: Identifiable {
    var id = UUID()
    var title: String
    var message: String
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
    }
}