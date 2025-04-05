import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showRegistration = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background from the app icon
                ColorTheme.backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Logo & Welcome Message
                    VStack(spacing: 20) {
                        Image("AppIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .padding(.bottom, 10)
                            
                        Text("Maternity Wellness")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textGray)
                        
                        Text("Support for new mothers in Singapore")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textGray)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                        
                        // Error message (if needed)
                        if showError {
                            Text("Invalid email or password")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Login Button
                        Button(action: {
                            // Demo login - accept any non-empty credentials
                            if !email.isEmpty && !password.isEmpty {
                                isLoggedIn = true
                            } else {
                                showError = true
                            }
                        }) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(ColorTheme.buttonGradient)
                                .cornerRadius(15)
                                .shadow(color: ColorTheme.primaryPink.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 10)
                        
                        // Registration Link
                        Button(action: {
                            showRegistration = true
                        }) {
                            Text("Don't have an account? Sign up")
                                .foregroundColor(ColorTheme.textGray)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Footer with version info
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textGray)
                        .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showRegistration) {
                RegistrationView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

struct RegistrationView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Personal Information").foregroundColor(ColorTheme.textGray)) {
                        TextField("Full Name", text: $name)
                            .foregroundColor(ColorTheme.textGray)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(ColorTheme.textGray)
                    }
                    
                    Section(header: Text("Security").foregroundColor(ColorTheme.textGray)) {
                        SecureField("Password", text: $password)
                        SecureField("Confirm Password", text: $confirmPassword)
                    }
                    
                    if showError {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    Section {
                        Button(action: registerUser) {
                            Text("Register")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(ColorTheme.buttonGradient)
                                .cornerRadius(10)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Create Account")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(ColorTheme.primaryPink)
                }
            }
        }
    }
    
    func registerUser() {
        // Validate inputs
        if name.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "All fields are required"
            showError = true
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords don't match"
            showError = true
            return
        }
        
        // Basic email validation
        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email"
            showError = true
            return
        }
        
        // For demo purposes, just log them in
        isLoggedIn = true
        presentationMode.wrappedValue.dismiss()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
