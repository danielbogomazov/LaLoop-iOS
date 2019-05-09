//
//  AppDelegate.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2018-12-21.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var tabBarController: UITabBarController!
    
    var browseNavController: UINavigationController!
    var browseViewController = BrowseViewController()
    
    var followingNavController: UINavigationController!
    var followingViewController = FollowingViewController()
    
    var settingsNavController: UINavigationController!
    var settingsViewController = SettingsViewController()
    
    static var recordings: [Recording] = []
    static var avant_garde_subgenres: [String] = []
    static var blues_subgenres: [String] = []
    static var caribbean_subgenres: [String] = []
    static var childrens_subgenres: [String] = []
    static var classical_subgenres: [String] = []
    static var comedy_subgenres: [String] = []
    static var country_subgenres: [String] = []
    static var electronic_subgenres: [String] = []
    static var experimental_subgenres: [String] = []
    static var folk_subgenres: [String] = []
    static var hip_hop_subgenres: [String] = []
    static var jazz_subgenres: [String] = []
    static var latin_subgenres: [String] = []
    static var pop_subgenres: [String] = []
    static var rnb_and_soul_subgenres: [String] = []
    static var rock_subgenres: [String] = []
    static var worship_subgenres: [String] = []
    
    static var persistentContainer: NSPersistentContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    static var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if !UserDefaults.standard.bool(forKey: Util.Keys.launchedBeforeKey) {
            Util.resetSettings()
        }
        
        // Remove navbar bottom border
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        browseNavController = UINavigationController(rootViewController: browseViewController)
        browseNavController.viewControllers = [browseViewController]
        setupNavController(for: browseNavController, title: "Browse", restorationIdentifier: "browseNavController", tabImage: #imageLiteral(resourceName: "Browse"), tabSelectedImage: #imageLiteral(resourceName: "BrowseSelected"))
        
        followingNavController = UINavigationController(rootViewController: followingViewController)
        followingNavController.viewControllers = [followingViewController]
        setupNavController(for: followingNavController, title: "Following", restorationIdentifier: "followingNavController", tabImage: #imageLiteral(resourceName: "Following"), tabSelectedImage: #imageLiteral(resourceName: "FollowingSelected"))
        
        settingsNavController = UINavigationController(rootViewController: settingsViewController)
        settingsNavController.viewControllers = [settingsViewController]
        setupNavController(for: settingsNavController, title: "Settings", restorationIdentifier: "settingsNavController", tabImage: #imageLiteral(resourceName: "Settings"), tabSelectedImage: #imageLiteral(resourceName: "SettingsSelected"))
        
        tabBarController = UITabBarController()
        tabBarController.delegate = self
        tabBarController.tabBar.barStyle = .blackOpaque
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.barTintColor = Util.Color.backgroundColor
        tabBarController.viewControllers = [browseNavController, followingNavController, settingsNavController]
        
        let loadingViewController = LoadingViewController()
        loadingViewController.presentViewController = tabBarController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = loadingViewController
        window?.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (didAllow, error) in
            if let e = error {
                print(e.localizedDescription)
                // TODO
            }
            if !didAllow {
                // TODO : User did not allow the use of notifications
                // Create an explination in the settings or as a popup to explain why it is needed
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Util.getData { (success) in
            success ? completionHandler(.newData) : completionHandler(.failed)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        browseViewController.populateRecordings()
        browseViewController.reloadTableView()
        followingViewController.populateArtists()
        followingViewController.reloadTableView()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "LaLoop")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Other helper functions
    
    func createTabBarItem(tabBarItem: UITabBarItem, image: UIImage, selectedImage: UIImage) {
        tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
        tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        tabBarItem.setTitleTextAttributes([.foregroundColor: Util.Color.main], for: .selected)
        tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
    
    func setupNavController(for nc: UINavigationController, title: String, restorationIdentifier: String, tabImage: UIImage, tabSelectedImage: UIImage) {
        nc.title = title
        nc.topViewController?.title = title
        nc.navigationBar.barStyle = .blackOpaque
        nc.navigationBar.isTranslucent = false
        nc.navigationBar.barTintColor = Util.Color.backgroundColor
        nc.restorationIdentifier = restorationIdentifier
        createTabBarItem(tabBarItem: nc.tabBarItem, image: tabImage, selectedImage: tabSelectedImage)
    }

}

// MARK: - UITabBarControllerDelegate
extension AppDelegate: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if tabBarController.selectedViewController == viewController {
            if let browseViewController = (viewController as? UINavigationController)?.topViewController as? BrowseViewController {
                browseViewController.scrollTableViewToTop()
            } else if let followViewController = (viewController as? UINavigationController)?.topViewController as? FollowingViewController {
                followViewController.scrollTableViewToTop()
            } else if let settingsViewController = (viewController as? UINavigationController)?.topViewController as? SettingsViewController {
                settingsViewController.scrollTableViewToTop()
            }
        }
        return true
    }
}
