import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let IsLightStatusBar = false
    static let HeaderSize = CGFloat(100)

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = self.window else { return false }

        let numberOfColumns = CGFloat(4)
        let layout = UICollectionViewFlowLayout()
        let bounds = UIScreen.main.bounds
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let size = (bounds.width - numberOfColumns) / numberOfColumns
        layout.itemSize = CGSize(width: size, height: size)
        layout.headerReferenceSize = CGSize(width: bounds.width, height: AppDelegate.HeaderSize);

        let remoteController = RemoteCollectionController(collectionViewLayout: layout)
        remoteController.title = "Remote"
        let remoteNavigationController = UINavigationController(rootViewController: remoteController)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [remoteNavigationController]

        if AppDelegate.IsLightStatusBar {
            UINavigationBar.appearance().barTintColor = UIColor.orange
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            remoteNavigationController.navigationBar.barStyle = .black
        }

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        return true
    }
}
