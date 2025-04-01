import SwiftUI

struct RegisterForm: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var fullName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // Validation states
    @State private var isEmailValid: Bool = true
    @State private var passwordsMatch: Bool = true
    
    var isFormValid: Bool {
        return !username.isEmpty &&
               !email.isEmpty && isEmailValid &&
               !fullName.isEmpty &&
               !password.isEmpty &&
               !confirmPassword.isEmpty &&
               passwordsMatch
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Full Name Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Full Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter your full name", text: $fullName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .disableAutocorrection(true)
            }
            
            // Username Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Username")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Choose a username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter your email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .onChange(of: email) { newValue in
                        isEmailValid = newValue.isEmpty || newValue.contains("@")
                    }
                
                if !isEmailValid {
                    Text("Please enter a valid email address")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("Create a password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .onChange(of: password) { _ in
                        passwordsMatch = password == confirmPassword || confirmPassword.isEmpty
                    }
            }
            
            // Confirm Password Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("Confirm your password", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .onChange(of: confirmPassword) { _ in
                        passwordsMatch = password == confirmPassword || confirmPassword.isEmpty
                    }
                
                if !passwordsMatch && !confirmPassword.isEmpty {
                    Text("Passwords do not match")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Terms and Privacy
            HStack {
                Text("By signing up, you agree to our ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    // Show terms
                }) {
                    Text("Terms & Privacy Policy")
                        .font(.caption)
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(.top, 4)
            
            // Register Button
            Button(action: {
                authViewModel.register(
                    username: username,
                    email: email,
                    fullName: fullName,
                    password: password
                )
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color("AccentColor"))
                .cornerRadius(8)
            }
            .disabled(authViewModel.isLoading || !isFormValid)
            .opacity(authViewModel.isLoading || !isFormValid ? 0.7 : 1)
        }
        .padding()
    }
}

struct RegisterForm_Previews: PreviewProvider {
    static var previews: some View {
        RegisterForm()
            .environmentObject(AuthViewModel())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}