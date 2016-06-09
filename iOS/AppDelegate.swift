import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let IsLightStatusBar = false
    static let HeaderSize = CGFloat(60)

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let numberOfColumns = CGFloat(4)
        let layout = UICollectionViewFlowLayout()
        let bounds = UIScreen.mainScreen().bounds
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let size = (bounds.width - numberOfColumns) / numberOfColumns
        layout.itemSize = CGSize(width: size, height: size)
        layout.sectionInset = UIEdgeInsets(top: AppDelegate.HeaderSize, left: 0, bottom: 10, right: 0)

        let remoteController = RemoteCollectionController(collectionViewLayout: layout)
        remoteController.title = "Remote"
        let remoteNavigationController = UINavigationController(rootViewController: remoteController)

        if AppDelegate.IsLightStatusBar {
            UINavigationBar.appearance().barTintColor = UIColor.orangeColor()
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            remoteNavigationController.navigationBar.barStyle = .Black
        }

        self.window?.rootViewController = remoteNavigationController
        self.window!.makeKeyAndVisible()

        return true
    }
}
