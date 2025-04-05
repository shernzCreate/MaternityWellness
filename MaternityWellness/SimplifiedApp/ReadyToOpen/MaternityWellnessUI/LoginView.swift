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
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Logo & Welcome Message
                    VStack(spacing: 20) {
                        Text("Maternity Wellness")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.blue)
                        
                        Text("Support for new mothers in Singapore")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
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
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                        
                        // Registration Link
                        Button(action: {
                            showRegistration = true
                        }) {
                            Text("Don't have an account? Sign up")
                                .foregroundColor(.blue)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Footer with version info
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.gray)
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
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Security")) {
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
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Create Account")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
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
