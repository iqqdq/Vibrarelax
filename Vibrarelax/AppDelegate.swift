//
//  AppDelegate.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 20.05.2021.
//

import UIKit
import Firebase
import FBSDKCoreKit
import StoreKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    var window: UIWindow?
    var onboardingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingViewController")
    let bottomNavigationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BottomNavigationViewController")
    let center = UNUserNotificationCenter.current()
    
    let subscriptionsIDs = ["weekly_sub", "monthly_sub", "annually_sub"]
    var products: [String: SKProduct] = [:]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = bottomNavigationViewController
        window?.makeKeyAndVisible()
        
        // Localization
        UserDefaults.standard.setValue(["ru"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Onboarding start date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ru_RU")
        
        if let startDate = formatter.date(from: "2021-06-22") {
            if Date() >= startDate {
                if UserDefaults.standard.bool(forKey: "onboarding") == false {
                    onboardingViewController.modalPresentationStyle = .fullScreen
                    bottomNavigationViewController.present(onboardingViewController, animated: false, completion: nil)
                }
            }
        }
        
        // Detect App First Launch
        requestAuthorizationPushNotifications()
        
        // Remove Push Notifications If Subscribed
        center.delegate = self
        if UserDefaults.standard.bool(forKey: "is_subscribed") == true {
            removeLocalPushNotifications()
        }
        
        // Set Deafult Mode
        UserDefaults.standard.setValue(0, forKey: "mode_id")
        
        // Subscription Check
        SKPaymentQueue.default().add(self)
        fetchProducts()
        
        if UserDefaults.standard.bool(forKey: "is_subscribed") == true {
            refreshSubscriptionsStatus()
        }
        
        // Firebase SDK
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
            
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            ApplicationDelegate.shared.application(app,
                                                   open: url,
                                                   sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                   annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    // MARK: -
    // MARK: - AUTORENEWABLE SUBSCRIPTION CHECK
    
    func fetchProducts() {
        let productIDs = Set([subscriptionsIDs[0], subscriptionsIDs[1], subscriptionsIDs[2]])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            print("Invalid: \(product)")
        }
        
        response.products.forEach { product in
            print("Valid: \(product)")
            products[product.productIdentifier] = product
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                queue.finishTransaction(transaction)
                print("Transaction Failed \(transaction)")
                // Dismiss Onboarding
                NotificationCenter.default.post(name: Notification.Name("close_onboarding"), object: nil)
            case .purchased, .restored:
                queue.finishTransaction(transaction)
                print("Transaction purchased or restored: \(transaction)")
            case .deferred, .purchasing:
                print("Transaction in progress: \(transaction)")
            @unknown default:
                break
            }
        }
        
        // Subscription Status
        refreshSubscriptionsStatus()
    }
    
    private func refreshReceipt(){
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
    }
    
    func refreshSubscriptionsStatus() {
        IndicatorView().show()
        
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            refreshReceipt()
            return
        }
        
        #if DEBUG
            let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
        #else
            let urlString = "https://buy.itunes.apple.com/verifyReceipt"
        #endif
        let receiptData = try? Data(contentsOf: receiptUrl).base64EncodedString()
        let requestData = ["receipt-data" : receiptData ?? "",
                           "password" : "5d4f071c8eaf45eb81ac0f5627dc2df2",
                           "exclude-old-transactions" : true] as [String : Any]
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            DispatchQueue.main.async {
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                        IndicatorView().hide()
                        self.parseReceipt(json as! Dictionary<String, Any>)
                        return
                    }
                } else {
                    print("error validating receipt: \(error?.localizedDescription ?? "")")
                }
            }
        }.resume()
    }
    
    private func parseReceipt(_ json : Dictionary<String, Any>) {
        UserDefaults.standard.set(false, forKey: "is_subscribed")
        
        guard let receipts_array = json["latest_receipt_info"] as? [Dictionary<String, Any>] else {
            return
        }
        
        var isFound: Bool = false
        
        for receipt in receipts_array {
            if let productID = receipt["product_id"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"

                if let expiresString = receipt["expires_date_ms"] as? String, let expiresMS = Double(expiresString) {
                    let expireDate = Date(timeIntervalSince1970: expiresMS / 1000.0)
                    print(dateFormatter.string(from: expireDate))
                    
                    if expireDate > Date() {
                        isFound = true
                        UserDefaults.standard.set(expireDate, forKey: productID)
                    }
                    
                    if let purchaseSring = receipt["purchase_date_ms"] as? String, let purchiseMS = Double(purchaseSring) {
                        if let cancellationString = receipt["cancellation_date_ms"] as? String, let cancellationMS = Double(cancellationString) {
                            let purchaseDate = Date(timeIntervalSince1970: purchiseMS / 1000.0)
                            print(dateFormatter.string(from: purchaseDate))
                        
                            let cancellationDate = Date(timeIntervalSince1970: cancellationMS / 1000.0)
                            print(dateFormatter.string(from: cancellationDate))
                        
                            if cancellationDate > purchaseDate {
                                isFound = false
                                UserDefaults.standard.set(false, forKey: "is_subscribed")
                            }
                        }
                    }
                }
            }
        }

        if isFound {
            UserDefaults.standard.set(true, forKey: "is_subscribed")
            NotificationCenter.default.post(name: Notification.Name("close_onboarding"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("show_all_modes"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("close_offer"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("hide_special_offer"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("hide_open_modes_button"), object: nil)
            removeLocalPushNotifications()
        }
    }
    
    // MARK: -
    // MARK: - LOCAL PUSH NOTIFICATIONS
    
    func requestAuthorizationPushNotifications() {
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Something went wrong")
            }
            
            self.center.getNotificationSettings(completionHandler: { settings in
              switch settings.authorizationStatus {
              case .authorized, .provisional:
                print("authorized")
                self.setupLocalPushNotifications()
              case .denied:
                print("denied")
              case .notDetermined:
                print("not determined, ask user for permission now")
              case .ephemeral:
                print("ephemeral")
              @unknown default:
                break
              }
            })
        }
    }
    
    func setupLocalPushNotifications() {
        let firstContent = UNMutableNotificationContent()
        firstContent.body = NotificationContent.first
        firstContent.sound = UNNotificationSound.default
        
        let secondContent = UNMutableNotificationContent()
        secondContent.body = NotificationContent.second
        secondContent.sound = UNNotificationSound.default
        
        let thirdContent = UNMutableNotificationContent()
        thirdContent.body = NotificationContent.third
        thirdContent.sound = UNNotificationSound.default
        
        let fourthContent = UNMutableNotificationContent()
        fourthContent.body = NotificationContent.fourth
        fourthContent.sound = UNNotificationSound.default
        
        let fifthContent = UNMutableNotificationContent()
        fifthContent.body = NotificationContent.fifth
        fifthContent.sound = UNNotificationSound.default
        
        let sixthContent = UNMutableNotificationContent()
        sixthContent.body = NotificationContent.sixth
        sixthContent.sound = UNNotificationSound.default
        
        let seventhContent  = UNMutableNotificationContent()
        seventhContent.body  = NotificationContent.seventh
        seventhContent.sound = UNNotificationSound.default
        
        let eighthContent = UNMutableNotificationContent()
        eighthContent.body = NotificationContent.eighth
        eighthContent.sound = UNNotificationSound.default
        
        let firstTrigger   = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400, repeats: false)
        let secondTrigger  = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400 * 3, repeats: false)
        let thirdTrigger   = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400 * 5, repeats: false)
        let fourthTrigger  = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400 * 8, repeats: false)
        let fifthTrigger   = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400 * 11, repeats: false)
        let sixthTrigger   = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400 * 14, repeats: false)
        let seventhTrigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400 * 17, repeats: false)
        let eighthTrigger  = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400 * 20, repeats: false)
        
        let notificationRequests: [UNNotificationRequest] = [
            UNNotificationRequest(identifier: "UYLLocalNotification1", content: firstContent, trigger: firstTrigger),
            UNNotificationRequest(identifier: "UYLLocalNotification2", content: secondContent, trigger: secondTrigger),
            UNNotificationRequest(identifier: "UYLLocalNotification3", content: thirdContent, trigger: thirdTrigger),
            UNNotificationRequest(identifier: "UYLLocalNotification4", content: fourthContent, trigger: fourthTrigger),
            UNNotificationRequest(identifier: "UYLLocalNotification5", content: fifthContent, trigger: fifthTrigger),
            UNNotificationRequest(identifier: "UYLLocalNotification6", content: sixthContent, trigger: sixthTrigger),
            UNNotificationRequest(identifier: "UYLLocalNotification7", content: seventhContent, trigger: seventhTrigger),
            UNNotificationRequest(identifier: "UYLLocalNotification8", content: eighthContent, trigger: eighthTrigger)
        ]
        
        for request in notificationRequests {
            center.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("Unable to show notification")
                }
            })
        }
    }
    
    func removeLocalPushNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
               completionHandler([.alert, .badge, .sound])
    }
}
