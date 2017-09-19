//
//  AppDelegate.swift
//  Display
//
//  Created by Roberth on 8/29/17.
//  Copyright © 2017 pinneapple. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var validCashRegisterInfo : Bool!
    
    let APIKEY = "APIKEY"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let apiKey = UserDefaults.standard.string(forKey: self.APIKEY) {
            self.validCashRegisterInfo = true
            print("the default APIKEY is \(apiKey)")
        }else{
            self.validCashRegisterInfo = false
            print("no default apiKey set ")
        }
        
        if let defaultCashRegisterID = UserDefaults.standard.string(forKey: "cashRegisterID") {
            self.validCashRegisterInfo = true
            print("the default cash register ID is \(defaultCashRegisterID)")
        }else{
            self.validCashRegisterInfo = false
            print("no default cash register ID set ")
        }
        
//        self.validCashRegisterInfo = false
        if self.validCashRegisterInfo {
            print("caja ya configurada")
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let controller = storyboard.instantiateViewController(withIdentifier: "viewcontroller")
            window?.rootViewController = controller
            //self.performSegue(withIdentifier: "segue1", sender: nil)
            
        }
        
        return true
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

