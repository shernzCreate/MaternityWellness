import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Check if user is logged in from keychain/UserDefaults on app start
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        // In a real implementation, would check keychain or UserDefaults
        // For now, we'll simulate a logged-out state
        isAuthenticated = false
        currentUser = nil
    }
    
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real implementation, would make a network request
            // and handle the response accordingly
            
            // For demo purposes, let's simulate a successful login
            if username.lowercased() == "demo" && password == "password" {
                self.currentUser = User(
                    username: username.lowercased(),
                    fullName: "Sarah Tan",
                    email: "sarah.tan@example.com"
                )
                self.isAuthenticated = true
                self.saveUserSession()
            } else {
                self.errorMessage = "Invalid username or password"
            }
            
            self.isLoading = false
        }
    }
    
    func register(username: String, email: String, fullName: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real implementation, would make a network request
            // and handle the response accordingly
            
            // For demo purposes, let's simulate a successful registration
            if username.count >= 3 {
                self.currentUser = User(
                    username: username.lowercased(),
                    fullName: fullName,
                    email: email
                )
                self.isAuthenticated = true
                self.saveUserSession()
            } else {
                self.errorMessage = "Username must be at least 3 characters"
            }
            
            self.isLoading = false
        }
    }
    
    func logout() {
        // Clear user session data
        UserDefaults.standard.removeObject(forKey: "user_session")
        
        // Update state
        currentUser = nil
        isAuthenticated = false
    }
    
    private func saveUserSession() {
        // In a real implementation, would save to keychain or secure storage
        UserDefaults.standard.set(true, forKey: "user_session")
    }
}