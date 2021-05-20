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
    var navigationController: UINavigationController?
    var identifier: String = "OnboardingViewController"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup Navigation
        navigationController = UINavigationController.init(rootViewController: OnboardingViewController())
        
        // Setup Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = #colorLiteral(red: 0.9904052615, green: 0.9024250507, blue: 0.8557242751, alpha: 1)
        
//        if UserDefaults.standard.bool(forKey: "onboarding") {
//            identifier = "BottomNavigationViewController"
//        }

        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationController")
        window?.makeKeyAndVisible()
            
        // Localization
        UserDefaults.standard.setValue(["ru"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
            
        return true
    }
}

