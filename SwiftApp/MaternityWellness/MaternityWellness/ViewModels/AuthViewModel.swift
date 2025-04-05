import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var loginError: String?
    @Published var signupError: String?
    
    init() {
        // In a real app, check for stored credentials or token here
        // For demo purposes, just set to false initially
        isLoggedIn = false
    }
    
    func login(email: String, password: String) {
        // Simulated authentication
        // In a real app, this would call an authentication API
        
        // For demo purposes, any non-empty credentials work
        if !email.isEmpty && !password.isEmpty {
            // Create a demo user
            let user = User(email: email, name: email.components(separatedBy: "@").first ?? "User")
            self.currentUser = user
            self.isLoggedIn = true
            self.loginError = nil
        } else {
            self.loginError = "Please enter your email and password"
        }
    }
    
    func signup(name: String, email: String, password: String, confirmPassword: String) {
        // Validation
        if name.isEmpty || email.isEmpty || password.isEmpty {
            signupError = "All fields are required"
            return
        }
        
        if password != confirmPassword {
            signupError = "Passwords do not match"
            return
        }
        
        // Email validation
        if !email.contains("@") || !email.contains(".") {
            signupError = "Please enter a valid email address"
            return
        }
        
        // In a real app, this would register the user with an API
        // For demo purposes, create a user locally
        let user = User(email: email, name: name)
        self.currentUser = user
        self.isLoggedIn = true
        self.signupError = nil
    }
    
    func logout() {
        // In a real app, clear tokens or session
        self.currentUser = nil
        self.isLoggedIn = false
    }
}