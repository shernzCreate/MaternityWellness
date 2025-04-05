import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Form fields
            VStack(spacing: 15) {
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .autocapitalization(.none)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            
            // Error message if any
            if let error = authViewModel.loginError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 20)
            }
            
            // Login button
            Button(action: {
                authViewModel.login(email: email, password: password)
            }) {
                Text("Login")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            
            // Forgot password link
            Button(action: {
                // Handle forgot password
            }) {
                Text("Forgot Password?")
                    .foregroundColor(Color("AccentColor"))
                    .font(.subheadline)
            }
            .padding(.top, 5)
            
            Spacer()
        }
        .padding(.top, 20)
    }
}