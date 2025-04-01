import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var passwordsMatch = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Full Name field
                VStack(alignment: .leading) {
                    Text("Full Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter your full name", text: $fullName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .disableAutocorrection(true)
                }
                
                // Username field
                VStack(alignment: .leading) {
                    Text("Username")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Choose a username", text: $username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }
                
                // Email field
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.emailAddress)
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
                            TextField("Create a password", text: $password)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Create a password", text: $password)
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
                    .onChange(of: password) { _ in
                        validatePasswords()
                    }
                }
                
                // Confirm Password field
                VStack(alignment: .leading) {
                    Text("Confirm Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        if showConfirmPassword {
                            TextField("Confirm your password", text: $confirmPassword)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Confirm your password", text: $confirmPassword)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        }
                        
                        Button(action: {
                            showConfirmPassword.toggle()
                        }) {
                            Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: confirmPassword) { _ in
                        validatePasswords()
                    }
                }
                
                // Password match warning
                if !passwordsMatch && !confirmPassword.isEmpty {
                    Text("Passwords do not match")
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                // Terms & Conditions
                Toggle(isOn: $agreeToTerms) {
                    HStack {
                        Text("I agree to the")
                            .font(.footnote)
                        
                        Button(action: {
                            // Show terms
                        }) {
                            Text("Terms & Conditions")
                                .font(.footnote)
                                .foregroundColor(Color("AccentColor"))
                                .underline()
                        }
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                
                // Error message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 5)
                }
                
                // Sign Up button
                Button(action: {
                    if validateForm() {
                        authViewModel.register(
                            username: username,
                            email: email,
                            password: password,
                            fullName: fullName
                        )
                    }
                }) {
                    HStack {
                        Text("Sign Up")
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
            }
            .padding()
        }
    }
    
    private func validatePasswords() {
        if !confirmPassword.isEmpty {
            passwordsMatch = password == confirmPassword
        } else {
            passwordsMatch = true
        }
    }
    
    private func validateForm() -> Bool {
        if fullName.isEmpty {
            authViewModel.errorMessage = "Please enter your full name"
            return false
        }
        
        if username.isEmpty {
            authViewModel.errorMessage = "Please choose a username"
            return false
        }
        
        if email.isEmpty || !isValidEmail(email) {
            authViewModel.errorMessage = "Please enter a valid email address"
            return false
        }
        
        if password.isEmpty || password.count < 6 {
            authViewModel.errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        if password != confirmPassword {
            authViewModel.errorMessage = "Passwords do not match"
            return false
        }
        
        if !agreeToTerms {
            authViewModel.errorMessage = "You must agree to the Terms & Conditions"
            return false
        }
        
        return true
    }
    
    private func formIsValid() -> Bool {
        return !fullName.isEmpty && 
               !username.isEmpty && 
               isValidEmail(email) && 
               password.count >= 6 && 
               password == confirmPassword && 
               agreeToTerms
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}