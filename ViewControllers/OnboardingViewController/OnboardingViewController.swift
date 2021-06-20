//
//  OnboardingViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 20.05.2021.
//

import UIKit
import GRView
import StoreKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: GRButton!
    @IBOutlet weak var firstIndicatorView: UIView!
    @IBOutlet weak var secondIndicatorView: UIView!
    @IBOutlet weak var thirdIndicatorView: UIView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var privacyViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsView: GRView!
    @IBOutlet weak var privacyView: GRView!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    
    let items: [[String : String]] = [["Welcome\nto Vibrarelax" : "The massage is relaxing. Our application will help you to relax, rest, improve your well-being at any time without any help."], ["Take a break from worries" : "Did you know that there are approximately 5 million receptors on our skin, with only 3000 on one fingertip?"], ["Try with\nall modes PRO" : "12 vibration modes, 5 speed modes, no ads, screen lock, weekly content update for $ 8.99 / week,\n3-Day Free Trial"]]
    let images: [String] = ["ic_onboarding_first", "ic_onboarding_second", "ic_onboarding_third"]
    var timer: Timer?
    var products: [String: SKProduct] = [:]
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeOnboarding), name: Notification.Name("close_onboarding"), object: nil)
        
        setupWaveAnimations()
        setupLayout()
        fetchProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        DispatchQueue.main.async {
            self.privacyView.roundCorners([.topLeft, .topRight], radius: 30.0)
            self.termsView.roundCorners([.topLeft, .topRight], radius: 30.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.privacyView.roundCorners([.topLeft, .topRight], radius: 30.0)
            self.termsView.roundCorners([.topLeft, .topRight], radius: 30.0)
        }
    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        if sender.tag == 2 {
            purchase()
        } else {
            collectionView.scrollToItem(at: IndexPath(item: sender.tag + 1, section: 0), at: .centeredHorizontally, animated: true)
            sender.tag += 1
        }
        
        updateIndicator()
    }
    
    @IBAction func restoreButtonAction(_ sender: UIButton) {
//        IndicatorView().show()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
        
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true) {
            UserDefaults.standard.setValue(true, forKey: "onboarding")
        }
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
    
    @IBAction func closeTermsButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 0.0
            self.termsViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func closePrivacyButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 0.0
            self.privacyViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func setupWaveAnimations() {
        let topWave = Wave(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2))
        topWave.direction = .right
        topWave.waveHeight = 100
        topWave.waveTop    = 0.5
        topWave.variance   = 50
        topWave.fps        = 80
        topWave.fillColor = #colorLiteral(red: 0.9294117647, green: 0.2666666667, blue: 0.3647058824, alpha: 1)
        topWave.stokeColor = #colorLiteral(red: 0.9294117647, green: 0.2666666667, blue: 0.3647058824, alpha: 1)
        topWave.backgroundColor = .clear
        topWave.waveWidth  = UIScreen.main.bounds.width * 1.5
        topWave.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        view.addSubview(topWave)
        
        let botWave = Wave(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.height - (UIScreen.main.bounds.height / 4), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 4))
        botWave.direction = .right
        botWave.waveHeight = 100
        botWave.waveTop    = 0.5
        botWave.variance   = 50
        botWave.fps        = 80
        botWave.fillColor = #colorLiteral(red: 0.8705882353, green: 0.7294117647, blue: 0.6666666667, alpha: 1)
        botWave.stokeColor = #colorLiteral(red: 0.8705882353, green: 0.7294117647, blue: 0.6666666667, alpha: 1)
        botWave.backgroundColor = .clear
        botWave.waveWidth  = UIScreen.main.bounds.width * 1.5
        view.addSubview(botWave)
        
        view.bringSubviewToFront(indicatorView)
        view.bringSubviewToFront(collectionView)
        view.bringSubviewToFront(continueButton)
        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(restoreButton)
        view.bringSubviewToFront(termsButton)
        view.bringSubviewToFront(privacyButton)
        view.bringSubviewToFront(separatorView)
        view.addSubview(visualEffectView)
        view.bringSubviewToFront(privacyView)
        view.bringSubviewToFront(termsView)
    }
    
    func setupLayout() {
        // Blur View
        visualEffectView.frame = UIScreen.main.bounds
        visualEffectView.blur.radius = 10.0
        visualEffectView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        visualEffectView.alpha = 0.0
    }
    
    func updateIndicator() {
        secondIndicatorView.backgroundColor = continueButton.tag >= 1 ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        thirdIndicatorView.backgroundColor = continueButton.tag > 1 ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        closeButton.isHidden = continueButton.tag == 2 ? false : true
        restoreButton.isHidden = continueButton.tag == 2 ? false : true
        print(continueButton.tag)
    }
    
    func fetchProducts() {
        let productIDs = Set(["weekly_sub"])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func purchase() {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else {
            return
        }
        
        if products.count > 0 {
            if let product = products["weekly_sub"] {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            }
        }
    }
    
    @objc func closeOnboarding() {
        dismiss(animated: true) {
            UserDefaults.standard.setValue(true, forKey: "onboarding")
        }
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell) {
                continueButton.tag = indexPath.row
            }
        }
        
        updateIndicator()
    }
}

extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let onboardingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath as IndexPath) as! OnboardingCollectionViewCell
        onboardingCollectionViewCell.topImageView.image = UIImage.init(named: images[indexPath.row])
        
        let item = items[indexPath.row];
        for (key, value) in item {
            onboardingCollectionViewCell.titleLabel.text = key
            onboardingCollectionViewCell.descriptionLabel.text = value
        }
        
        switch indexPath.row {
        case 1:
            onboardingCollectionViewCell.widthConstraint.constant = 167.0
            onboardingCollectionViewCell.heightConstraint.constant = 146.0
        case 2:
            onboardingCollectionViewCell.widthConstraint.constant = 178.0
            onboardingCollectionViewCell.heightConstraint.constant = 154.0
        default:
            onboardingCollectionViewCell.widthConstraint.constant = 154.0
            onboardingCollectionViewCell.heightConstraint.constant = 140.0
        }
        
        onboardingCollectionViewCell.imageViewYConstraint.constant = -124.0
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1334:
                print("iPhone 6/6S/7/8")
                onboardingCollectionViewCell.topImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            default:
                onboardingCollectionViewCell.topImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }

        return onboardingCollectionViewCell
    }
}

extension OnboardingViewController: SKProductsRequestDelegate {
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

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
