import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - Properties
    
    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window with frame matching the screen bounds
        window = UIWindow(windowScene: windowScene)
        
        // Set the root view controller
        let rootViewController = ViewController()
        window?.rootViewController = rootViewController
        
        // Make window visible
        window?.makeKeyAndVisible()
        
        // Handle any deep links that were provided at launch
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
        
        // Handle any URL schemes that were used to open the app
        if let url = connectionOptions.urlContexts.first?.url {
            handleURL(url)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        // Reset badge count to zero when app becomes active
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // MARK: - Deep Linking
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Handle the NSUserActivity to support deep linking
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }
        
        handleURL(url)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Handle URL schemes
        guard let url = URLContexts.first?.url else {
            return
        }
        
        handleURL(url)
    }
    
    // MARK: - URL Handling
    
    private func handleURL(_ url: URL) {
        // Process deep link URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        // Get path components
        let pathComponents = components.path.components(separatedBy: "/").filter { !$0.isEmpty }
        
        // Handle different paths
        if pathComponents.count > 0 {
            switch pathComponents[0] {
            case "assessment":
                // Navigate to assessment page
                navigateToAssessment()
            case "resources":
                // Navigate to resources page, possibly with a specific resource ID
                if pathComponents.count > 1 {
                    let resourceId = pathComponents[1]
                    navigateToResource(withId: resourceId)
                } else {
                    navigateToResources()
                }
            case "care-plan":
                // Navigate to care plan page
                navigateToCareplan()
            default:
                // Default to home page
                navigateToHome()
            }
        } else {
            // Default to home page if no specific path
            navigateToHome()
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToHome() {
        // This would be implemented by communicating with the WKWebView
        // to navigate to the home page
        guard let rootViewController = window?.rootViewController as? ViewController else {
            return
        }
        
        rootViewController.navigateToPath("/")
    }
    
    private func navigateToAssessment() {
        guard let rootViewController = window?.rootViewController as? ViewController else {
            return
        }
        
        rootViewController.navigateToPath("/assessment")
    }
    
    private func navigateToResources() {
        guard let rootViewController = window?.rootViewController as? ViewController else {
            return
        }
        
        rootViewController.navigateToPath("/resources")
    }
    
    private func navigateToResource(withId id: String) {
        guard let rootViewController = window?.rootViewController as? ViewController else {
            return
        }
        
        rootViewController.navigateToPath("/resources/\(id)")
    }
    
    private func navigateToCareplan() {
        guard let rootViewController = window?.rootViewController as? ViewController else {
            return
        }
        
        rootViewController.navigateToPath("/care-plan")
    }
}