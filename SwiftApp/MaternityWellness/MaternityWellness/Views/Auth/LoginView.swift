import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Username field
            VStack(alignment: .leading) {
                Text("Username")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter your username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
            
            // Password field
            VStack(alignment: .leading) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    } else {
                        SecureField("Enter your password", text: $password)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Forgot password link
            Button(action: {
                // Handle forgot password
            }) {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .underline()
                    .foregroundColor(Color("AccentColor"))
            }
            .padding(.top, 5)
            
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }
            
            // Login button
            Button(action: {
                if validateForm() {
                    authViewModel.login(username: username, password: password)
                }
            }) {
                HStack {
                    Text("Login")
                        .fontWeight(.bold)
                    
                    if authViewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(formIsValid() ? Color("AccentColor") : Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(!formIsValid() || authViewModel.isLoading)
            .padding(.top, 10)
        }
        .padding()
    }
    
    private func validateForm() -> Bool {
        if username.isEmpty {
            authViewModel.errorMessage = "Please enter your username"
            return false
        }
        
        if password.isEmpty {
            authViewModel.errorMessage = "Please enter your password"
            return false
        }
        
        return true
    }
    
    private func formIsValid() -> Bool {
        return !username.isEmpty && !password.isEmpty
    }
}