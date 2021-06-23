//
//  OfferViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 22.05.2021.
//

import UIKit
import GRView
import StoreKit

class OfferViewController: UIViewController {
    @IBOutlet weak var brillImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var brillImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstRowHiddenLabel: UILabel!
    @IBOutlet weak var secondRowHiddenLabel: UILabel!
    @IBOutlet weak var proLabelYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var proLabel: UILabel!
    @IBOutlet weak var policyView: GRView!
    @IBOutlet weak var termsView: GRView!
    @IBOutlet weak var privacyViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsViewBottomConstraint: NSLayoutConstraint!
    
    var products: [String: SKProduct] = [:]
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeOffer), name: Notification.Name("close_offer"), object: nil)
        
        fetchProducts()
        setupBlurView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1334:
                print("iPhone 6/6S/7/8")
                proLabel.font = UIFont.init(name: "Nunito-ExtraBold", size: 82.0)!
                brillImageViewWidthConstraint.constant = 192.0
                brillImageViewHeightConstraint.constant = 165.0
                proLabelYConstraint.constant = -20.0
                firstRowHiddenLabel.removeFromSuperview()
                secondRowHiddenLabel.removeFromSuperview()
            default:
                print("")
            }
        }
        
        DispatchQueue.main.async {
            self.policyView.roundCorners([.topLeft, .topRight], radius: 30.0)
            self.termsView.roundCorners([.topLeft, .topRight], radius: 30.0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ru_RU")
        if let startDate = formatter.date(from: "2021-06-08") {
            if Date() >= startDate {
                if UserDefaults.standard.bool(forKey: "is_subscribed") == false {
                    NotificationCenter.default.post(name: Notification.Name("default_slider_value"), object: nil)
                }
            }
        }
    }
    
    // MARK: -
    // MARK: - PAYMENT SUBSCRIPTION METHODS
    
    func fetchProducts() {
        let productIDs = Set(["weekly_sub", "monthly_sub", "annually_sub"])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func purchase(productID: String) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else {
            return
        }
        
        if products.count > 0 {
            if let product = products[productID] {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
                IndicatorView().show()
            }
        }
    }
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func setupBlurView() {
        visualEffectView.frame = UIScreen.main.bounds
        visualEffectView.blur.radius = 10.0
        visualEffectView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        visualEffectView.alpha = 0.0
        view.addSubview(visualEffectView)
        view.bringSubviewToFront(policyView)
        view.bringSubviewToFront(termsView)
    }
    
    @objc func closeOffer() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func restoreButtonAction(_ sender: UIButton) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yearlyButtonAction(_ sender: UIButton) {
        purchase(productID: "annually_sub")
    }
    
    @IBAction func monthlyButtonAction(_ sender: UIButton) {
        purchase(productID: "monthly_sub")
    }
    
    @IBAction func privacyButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 1.0
            self.privacyViewBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func termsButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 1.0
            self.termsViewBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func closePrivacyButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 0.0
            self.privacyViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func closeTermsButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 0.0
            self.termsViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        }
    }
}

extension OfferViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            print("Invalid: \(product)")
        }
        
        response.products.forEach { product in
            print("Valid: \(product)")
            products[product.productIdentifier] = product
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
    }
}
