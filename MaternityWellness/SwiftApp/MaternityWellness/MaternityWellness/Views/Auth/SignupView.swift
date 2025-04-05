import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Form fields
            VStack(spacing: 15) {
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter your name", text: $name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
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
                
                // Confirm Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        if isConfirmPasswordVisible {
                            TextField("Confirm your password", text: $confirmPassword)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Confirm your password", text: $confirmPassword)
                                .autocapitalization(.none)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
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
            if let error = authViewModel.signupError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 20)
            }
            
            // Sign up button
            Button(action: {
                authViewModel.signup(name: name, email: email, password: password, confirmPassword: confirmPassword)
            }) {
                Text("Create Account")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            
            // Terms and privacy
            Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding(.top, 20)
    }
}