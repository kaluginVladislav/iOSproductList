//
//  AppDelegate.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 15.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Customization after application launch.

        // Configure firebase services
        FirebaseApp.configure()

        // Recover file logs to memory to continue working in a new session
        LogFileManager.shared.insertMessagesFromFileToMemory(at: 0) { (result) in
            switch result {
            case .success:
                Log.info("LogFileManager did save messages from file to memory successfully")
            case .failure(let error):
                Log.error("LogFileManager did failure save messages from file to memory with error description: \(error.localizedDescription)")
            }
        }

        Log.info("Application did finish launching \(launchOptions == nil ? "without options" : "with options: \(launchOptions!)")")

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.

        // Attempts to commit unsaved changes to store before the application terminates.
        Log.shared.appendMessagesToFileImmediately = true

        // Save logs from memory to file for restore in second session
        LogFileManager.shared.setMessagesFromMemoryToFile { (result) in
            switch result {
            case .success:
                Log.info("LogFileManager did save messages from memory to file successfully")
            case .failure(let error):
                Log.error("LogFileManager did failure save messages from memory to file with error description: \(error.localizedDescription)")
            }
        }

        // Save core data context
        CoreDataManager.shared.saveAllContexts { (result) in
            switch result {
            case .success:
                Log.info("CoreDataManager did save context successfully")
            case .failure(let error):
                Log.fault("CoreDataManager did failure save context with unresolved error description: \(error.localizedDescription)")
            }
        }

        Log.info("Application will terminate")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        Log.info("Application will enter foreground")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        Log.info("Application did enter background")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        Log.info("Application will resign active")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        Log.info("Application did become active")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Select a configuration to create the new scene with.

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
