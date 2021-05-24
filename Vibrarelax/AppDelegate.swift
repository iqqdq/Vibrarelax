//
//  AppDelegate.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 20.05.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup Window
        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: UserDefaults.standard.bool(forKey: "onboarding") ? "BottomNavigationViewController" : "NavigationController")
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationController")
        window?.makeKeyAndVisible()
            
        // Localization
        UserDefaults.standard.setValue(["ru"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
            
        return true
    }
}

