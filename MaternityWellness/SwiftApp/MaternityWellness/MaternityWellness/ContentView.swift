import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            // Check for iOS 17 features availability
            if #available(iOS 17.0, *) {
                print("Running on iOS 17 or later")
            } else {
                print("Running on iOS version earlier than 17")
            }
        }
    }
}
