import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let IsLightStatusBar = false
    static let HeaderSize = CGFloat(100)

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = self.window else { return false }

        let remoteController = RemoteCollectionController()
        remoteController.title = "Remote"
        let remoteNavigationController = UINavigationController(rootViewController: remoteController)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [remoteNavigationController]

        #if os(iOS)
            if AppDelegate.IsLightStatusBar {
                UINavigationBar.appearance().barTintColor = UIColor.orange
                UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
                remoteNavigationController.navigationBar.barStyle = .black
            }
        #endif

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        return true
    }
}
