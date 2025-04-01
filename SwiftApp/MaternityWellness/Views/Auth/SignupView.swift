import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var fullName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreeToTerms: Bool = false
    
    private var isFormValid: Bool {
        !username.isEmpty && 
        !email.isEmpty && 
        !fullName.isEmpty && 
        !password.isEmpty && 
        password == confirmPassword && 
        agreeToTerms &&
        password.count >= 6
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Form fields
            VStack(spacing: 15) {
                TextField("Full Name", text: $fullName)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                // Password strength indicator
                if !password.isEmpty {
                    HStack(spacing: 10) {
                        passwordStrengthBar(strength: passwordStrength)
                        Text(passwordStrengthText)
                            .font(.caption)
                            .foregroundColor(passwordStrengthColor)
                    }
                    .padding(.top, 5)
                }
                
                // Agree to terms checkbox
                Button(action: {
                    agreeToTerms.toggle()
                }) {
                    HStack {
                        Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                            .foregroundColor(agreeToTerms ? Color("AccentColor") : .gray)
                        
                        Text("I agree to the Terms and Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.vertical, 5)
            }
            .padding(.horizontal, 20)
            
            // Signup button
            Button(action: {
                authViewModel.register(
                    username: username,
                    email: email,
                    fullName: fullName,
                    password: password
                )
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("AccentColor"))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .disabled(!isFormValid || authViewModel.isLoading)
            .opacity((!isFormValid || authViewModel.isLoading) ? 0.6 : 1.0)
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    // Password strength indicator
    private var passwordStrength: Double {
        guard !password.isEmpty else { return 0 }
        
        var strength = 0.0
        
        // Length check
        if password.count >= 8 {
            strength += 0.25
        } else if password.count >= 6 {
            strength += 0.15
        }
        
        // Complexity checks
        let hasUppercase = password.contains { $0.isUppercase }
        let hasLowercase = password.contains { $0.isLowercase }
        let hasDigits = password.contains { $0.isNumber }
        let hasSpecialChars = password.contains { "!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?".contains($0) }
        
        if hasUppercase { strength += 0.25 }
        if hasLowercase { strength += 0.10 }
        if hasDigits { strength += 0.20 }
        if hasSpecialChars { strength += 0.20 }
        
        return min(1.0, strength)
    }
    
    private var passwordStrengthText: String {
        switch passwordStrength {
        case 0..<0.3:
            return "Weak"
        case 0.3..<0.6:
            return "Moderate"
        case 0.6..<0.8:
            return "Strong"
        default:
            return "Very Strong"
        }
    }
    
    private var passwordStrengthColor: Color {
        switch passwordStrength {
        case 0..<0.3:
            return .red
        case 0.3..<0.6:
            return .orange
        case 0.6..<0.8:
            return .yellow
        default:
            return .green
        }
    }
    
    private func passwordStrengthBar(strength: Double) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: geometry.size.width, height: 4)
                
                Rectangle()
                    .fill(passwordStrengthColor)
                    .frame(width: geometry.size.width * CGFloat(strength), height: 4)
            }
        }
        .frame(height: 4)
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .environmentObject(AuthViewModel())
    }
}