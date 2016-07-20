import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let IsLightStatusBar = false
    static let HeaderSize = CGFloat(100)

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        guard let window = self.window else { return false }

        let numberOfColumns = CGFloat(4)
        let layout = UICollectionViewFlowLayout()
        let bounds = UIScreen.mainScreen().bounds
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let size = (bounds.width - numberOfColumns) / numberOfColumns
        layout.itemSize = CGSize(width: size, height: size)
        layout.headerReferenceSize = CGSizeMake(bounds.width, AppDelegate.HeaderSize);

        let remoteController = RemoteCollectionController(collectionViewLayout: layout)
        remoteController.title = "Remote"
        let remoteNavigationController = UINavigationController(rootViewController: remoteController)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [remoteNavigationController]

        if AppDelegate.IsLightStatusBar {
            UINavigationBar.appearance().barTintColor = UIColor.orangeColor()
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            remoteNavigationController.navigationBar.barStyle = .Black
        }

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        return true
    }
}
