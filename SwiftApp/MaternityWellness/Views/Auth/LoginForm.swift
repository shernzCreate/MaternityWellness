import SwiftUI

struct LoginForm: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Username Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Username")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter your username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Forgot Password Link
            HStack {
                Spacer()
                Button(action: {
                    // Handle forgot password
                }) {
                    Text("Forgot Password?")
                        .font(.subheadline)
                        .foregroundColor(Color("AccentColor"))
                }
            }
            
            // Login Button
            Button(action: {
                authViewModel.login(username: username, password: password)
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color("AccentColor"))
                .cornerRadius(8)
            }
            .disabled(authViewModel.isLoading || username.isEmpty || password.isEmpty)
            .opacity(authViewModel.isLoading || username.isEmpty || password.isEmpty ? 0.7 : 1)
        }
        .padding()
    }
}

struct LoginForm_Previews: PreviewProvider {
    static var previews: some View {
        LoginForm()
            .environmentObject(AuthViewModel())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}