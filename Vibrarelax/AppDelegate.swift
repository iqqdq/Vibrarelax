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

@main
class AppDelegate: UIResponder, UIApplicationDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    var window: UIWindow?
    let subscriptionsIDs = ["weekly_sub", "monthly_sub", "annually_sub"]
    var products: [String: SKProduct] = [:]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup Window
        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: UserDefaults.standard.bool(forKey: "onboarding") ? "BottomNavigationViewController" : "NavigationController")
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BottomNavigationViewController")
        
        if UserDefaults.standard.bool(forKey: "is_subscribed") == true {
            window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BottomNavigationViewController")
        }
        
        window?.makeKeyAndVisible()
            
        // Localization
        UserDefaults.standard.setValue(["ru"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Set Deafult Mode
        UserDefaults.standard.setValue(0, forKey: "mode_id")
        
        // Firebase SDK
        FirebaseApp.configure()
        
        // Subscription Check
        SKPaymentQueue.default().add(self)
        fetchProducts()
        refreshSubscriptionsStatus()
            
        return true
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
            case .purchased, .restored:
                queue.finishTransaction(transaction)
                print("Transaction purchased or restored: \(transaction)")
            case .deferred, .purchasing:
                print("Transaction in progress: \(transaction)")
            @unknown default:
                break
            }
        }
        
        refreshSubscriptionsStatus()
    }
    
    private func refreshReceipt(){
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
    }
    
    func refreshSubscriptionsStatus() {
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
        let requestData = ["receipt-data" : receiptData ?? "", "password" : "5d4f071c8eaf45eb81ac0f5627dc2df2", "exclude-old-transactions" : true] as [String : Any]
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            DispatchQueue.main.async {
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
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
                if productID == "lifetime_sub" {
                    UserDefaults.standard.set(true, forKey: "is_subscribed")
                    NotificationCenter.default.post(name: Notification.Name("show_all_modes"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name("close_offer"), object: nil)
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                
                if let date = formatter.date(from: receipt["purchase_date"] as! String) {
                    if date > Date() {
                        isFound = true
                        UserDefaults.standard.set(date, forKey: productID)
                    }
                }
            }
        }

        if isFound {
            UserDefaults.standard.set(true, forKey: "is_subscribed")
            NotificationCenter.default.post(name: Notification.Name("show_all_modes"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("close_offer"), object: nil)
        }
    }
}

