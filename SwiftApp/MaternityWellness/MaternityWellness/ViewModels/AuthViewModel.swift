import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // For development and testing purposes
    // In a real app, this would be connected to a backend
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Simple validation for development
            if username.lowercased() == "test" && password == "password" {
                let user = User(
                    id: UUID().uuidString,
                    username: username,
                    email: "test@example.com",
                    fullName: "Test User"
                )
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Invalid username or password"
            }
            
            self.isLoading = false
        }
    }
    
    func register(username: String, email: String, password: String, fullName: String) {
        isLoading = true
        errorMessage = nil
        
        // Validate input
        if username.isEmpty || email.isEmpty || password.isEmpty || fullName.isEmpty {
            errorMessage = "All fields are required"
            isLoading = false
            return
        }
        
        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Create new user
            let user = User(
                id: UUID().uuidString,
                username: username,
                email: email,
                fullName: fullName
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}