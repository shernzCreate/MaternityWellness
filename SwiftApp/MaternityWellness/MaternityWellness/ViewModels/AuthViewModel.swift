import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // In a real app, you would implement proper authentication with your backend
    // For demo purposes, we're using simple mock functionality
    
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // For demo, accept any non-empty username/password
            if !username.isEmpty && !password.isEmpty {
                // Demo user
                let user = User(
                    id: 1,
                    username: username,
                    email: "\(username)@example.com",
                    fullName: "Jane Smith",
                    createdAt: Date()
                )
                
                self.currentUser = user
                self.isAuthenticated = true
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                // In a real app, would store a token
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
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Mock successful registration
            let user = User(
                id: 1,
                username: username,
                email: email,
                fullName: fullName,
                createdAt: Date()
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            self.isLoading = false
        }
    }
    
    func logout() {
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentUser = nil
            self.isAuthenticated = false
            UserDefaults.standard.set(false, forKey: "isAuthenticated")
            self.isLoading = false
        }
    }
    
    func checkAuthStatus() {
        // In a real app, you would validate a stored token with your backend
        // For demo purposes, we're just checking a simple flag
        let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        
        if isAuthenticated {
            // Create a mock user
            self.currentUser = User(
                id: 1,
                username: "demo_user",
                email: "demo@example.com",
                fullName: "Jane Smith",
                createdAt: Date()
            )
            
            self.isAuthenticated = true
        }
    }
}