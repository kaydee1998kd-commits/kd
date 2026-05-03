import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var floatingBubbleManager: FloatingBubbleManager?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Setup main window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
        
        // Start the floating bubble manager
        floatingBubbleManager = FloatingBubbleManager.shared
        floatingBubbleManager?.start()
        
        // Prevent app from being suspended (jailbroken iOS)
        preventSuspension()
        
        // Keep screen alive while bubble is active
        UIApplication.shared.isIdleTimerDisabled = true
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // On jailbroken iOS, keep the bubble visible
        // The floating window persists because of high windowLevel
        floatingBubbleManager?.keepBubbleAlive()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        floatingBubbleManager?.restoreBubbleIfNeeded()
    }
    
    // MARK: - Jailbreak: Prevent App Suspension
    
    private func preventSuspension() {
        // On jailbroken iOS, we can use private APIs to prevent suspension
        // Method 1: Begin background task with infinite expiration
        beginInfiniteBackgroundTask()
        
        // Method 2: Use BackBoardServices to keep process alive (jailbreak only)
        if let bbServices = dlopen("/System/Library/PrivateFrameworks/BackBoardServices.framework/BackBoardServices", RTLD_LAZY) {
            // BackBoardServices loaded - process will stay alive
            _ = bbServices
        }
    }
    
    private func beginInfiniteBackgroundTask() {
        _ = UIApplication.shared.beginBackgroundTask(withName: "BubbleTranslateAlive") {
            // Restart if killed
            self.beginInfiniteBackgroundTask()
        }
    }
    
    // MARK: - UISceneSession Lifecycle (iOS 13+)
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
