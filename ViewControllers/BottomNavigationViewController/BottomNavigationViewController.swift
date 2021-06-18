//
//  BottomNavigationViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 20.05.2021.
//

import UIKit
import FittedSheets
import GRView
import Blurberry
import StoreKit

class BottomNavigationViewController: UIViewController {
    @IBOutlet weak var navigationBarView: GRView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var lockButton: GRButton!
    @IBOutlet weak var firstTabButton: UIButton!
    @IBOutlet weak var secondTabButton: UIButton!
    @IBOutlet weak var thirdTabButton: UIButton!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var offerRoundCornerView: UIView!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var offerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var openSeasonsButton: GRButton!
    @IBOutlet weak var unlockImageView: UIImageView!
    @IBOutlet weak var noVibroView: GRView!
    @IBOutlet weak var noVibroBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeOfferButton: UIButton!
    @IBOutlet weak var termsView: GRView!
    @IBOutlet weak var privacyView: GRView!
    @IBOutlet weak var privacyViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsViewBottomConstraint: NSLayoutConstraint!
    
    var pageController: UIPageViewController!
    let modesViewConroller = ModesViewController()
    var viewControllers = [UIViewController]()
    var index = Int()
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var isLocked: Bool = false
    var lockTimer: Timer?
    var countdownTimer: Timer?
    var minutes: Int = 19
    var seconds: Int = 59
    var products: [String: SKProduct] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(lockScreen), name: Notification.Name("lockscreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNoVibroView), name: Notification.Name("no_vibro"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOfferView), name: Notification.Name("special_offer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeOfferView), name: Notification.Name("hide_special_offer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideUnlockImageView), name: Notification.Name("show_all_modes"), object: nil)
        
        fetchProducts()
        createPageViewController()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = String()
        navigationController?.setNavigationBarHidden(true, animated: true)

        DispatchQueue.main.async {
            self.offerViewBottomConstraint.constant = -1000.0
            self.offerRoundCornerView.roundCorners([.topLeft, .topRight], radius: 40.0)
            self.privacyView.roundCorners([.topLeft, .topRight], radius: 30.0)
            self.termsView.roundCorners([.topLeft, .topRight], radius: 30.0)
        }
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1334:
                    print("iPhone 6/6S/7/8")
                    self.unlockImageHeightConstraint.constant = 330.0
                case 1920, 2208:
                    print("iPhone 6+/6S+/7+/8+")
                    self.unlockImageHeightConstraint.constant = 346.0
                    self.unlockImageView.contentMode = .scaleToFill
                default:
                    print("LARGE IPHONE")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false  
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        countdownTimer = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func openSeasonsButtonAction(_ sender: UIButton) {
        present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "OfferViewController"), animated: true, completion: nil)
    }
    
    @IBAction func tabButtonAction(_ sender: UIButton) {
        selectTab(index: sender.tag)
    }
    
    @IBAction func lockButtonTouchDownAction(_ sender: UIButton) {
        if isLocked {
            isLocked = true
            lockTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1.75), target: self, selector: #selector(unlockScreen), userInfo: nil, repeats: false)
        } else {
            UIView.animate(withDuration: 0.3) {
                self.lockButton.alpha = 0.0
                self.blockView.alpha = 0.0
                self.visualEffectView.alpha = 0.0
            }
        }
    }
    
    @IBAction func lockButtonTouchUpInsideAction(_ sender: UIButton) {
        lockTimer?.invalidate()
    }
    
    @IBAction func lockButtonTouchUpOutsideAction(_ sender: UIButton) {
        lockTimer?.invalidate()
    }
    
    @IBAction func offerButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 0.0
            self.offerViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        } completion: { (finish) in
            self.purchase()
            self.countdownTimer?.invalidate()
        }
    }
    
    @IBAction func closeOfferButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 0.0
            self.offerViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        } completion: { (finish) in
            self.countdownTimer?.invalidate()
        }
    }
    
    @IBAction func closeNoVibroButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 0.0
            self.noVibroBottomConstraint.constant = -1000
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func privacyButtonAction(_ sender: UIButton) {
        view.bringSubviewToFront(privacyView)
        
        UIView.animate(withDuration: 0.3) {
            self.offerViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        } completion: { finish in
            UIView.animate(withDuration: 0.3) {
                self.privacyViewBottomConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func termsButtonAction(_ sender: UIButton) {
        view.bringSubviewToFront(termsView)
        
        UIView.animate(withDuration: 0.3) {
            self.offerViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        } completion: { finish in
            UIView.animate(withDuration: 0.3) {
                self.termsViewBottomConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func closeTermsButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.termsViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        } completion: { finish in
            UIView.animate(withDuration: 0.3) {
                self.offerViewBottomConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func closePrivacyButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.privacyViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        } completion: { finish in
            UIView.animate(withDuration: 0.3) {
                self.offerViewBottomConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func restoreButtonAction(_ sender: UIButton) {
        countdownTimer?.invalidate()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func selectTab(index: Int) {
        if UserDefaults.standard.bool(forKey: "is_subscribed") == true {
            openSeasonsButton.isHidden = true
            unlockImageView.isHidden = true
        } else {
            openSeasonsButton.isHidden = index == 0 ? false : true
            unlockImageView.isHidden =  index == 0 ? false : true
        }
        
        for subview in buttonStackView.subviews {
            if let button = subview as? UIButton {
                if button.tag == index {
                    button.isSelected = true
                    self.index = index
                    pageController.setViewControllers([viewControllers[self.index]], direction: .forward, animated: false, completion: nil)
                } else {
                    button.isSelected = false
                }
            }
        }
    }
    
    func setupLayout() {
        // Blur View
        visualEffectView.frame = UIScreen.main.bounds
        visualEffectView.blur.radius = 10.0
        visualEffectView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        visualEffectView.alpha = 0.0
    }
    
    @objc func hideUnlockImageView() {
        openSeasonsButton.isHidden =  true
        unlockImageView.isHidden = true
    }
    
    @objc func showNoVibroView() {
        view.bringSubviewToFront(noVibroView)
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 1.0
            self.noVibroBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func lockScreen() {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 1.0
            self.view.bringSubviewToFront(self.visualEffectView)
            
            self.blockView.alpha = 1.0
            self.view.bringSubviewToFront(self.blockView)
            
            self.lockButton.alpha = 1.0
            self.view.bringSubviewToFront(self.lockButton)
        } completion: { (finish) in
            self.isLocked = true
        }
    }
    
    @objc func unlockScreen() {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 0.0
            self.blockView.alpha = 0.0
            self.lockButton.alpha = 0.0
        } completion: { (finish) in
            self.isLocked = true
        }
    }
    
    @objc func countdouwn() {
        if minutes == 0 && seconds == 0 {
            minutes = 19
            seconds = 59
        } else {
            seconds = seconds == 0 ? 59 : seconds - 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.minutesLabel.textColor = self.minutes == 0 ? #colorLiteral(red: 0.9254901961, green: 0.831372549, blue: 0.7882352941, alpha: 1) : #colorLiteral(red: 0.9764705882, green: 0.3450980392, blue: 0.4352941176, alpha: 1)
            self.minutesLabel.text = self.minutes == 0 ? "00" : String(self.minutes).count > 1 ? "\(self.minutes)" : "0\(self.minutes)"
            self.secondsLabel.text = String(self.seconds).count > 1 ? "\(self.seconds)" : "0\(self.seconds)"
        }
    }
    
    @objc func showOfferView() {
        countdownTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self, selector: #selector(countdouwn), userInfo: nil, repeats: true)
           
        view.bringSubviewToFront(offerView)
          
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UIView.animate(withDuration: 0.15) {
                self.visualEffectView.alpha = 1.0
            } completion: { finish in
                UIView.animate(withDuration: 0.15) {
                    self.offerViewBottomConstraint.constant = 0.0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func closeOfferView() {
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 0.0
            self.offerViewBottomConstraint.constant = -1000.0
            self.view.layoutIfNeeded()
        } completion: { (finish) in
            self.countdownTimer?.invalidate()
        }
    }
    
    // MARK: -
    // MARK: - PURCHASING
    
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

    // MARK: -
    // MARK: - CREATE PAGE CONTROLLER
    
    func indexOfViewController(viewController: UIViewController) -> Int {
        if viewControllers.contains(viewController) {
            return viewControllers.firstIndex(of: viewController)!
        }
        return -1
    }
    
    func createPageViewController() {
        firstTabButton.setImage(#imageLiteral(resourceName: "ic_insense_selected"), for: .selected)
        secondTabButton.setImage(#imageLiteral(resourceName: "ic_fibro_selected"), for: .selected)
        thirdTabButton.setImage(#imageLiteral(resourceName: "ic_setting_selected"), for: .selected)

        pageController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.delegate = self
        pageController.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pageController.view.frame = self.view.frame
            self.view.bringSubviewToFront(self.unlockImageView)
            self.view.bringSubviewToFront(self.openSeasonsButton)
            self.view.bringSubviewToFront(self.navigationBarView)
            self.view.bringSubviewToFront(self.visualEffectView)
        }
        
        viewControllers = [UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "ModesViewController"),
                           UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "VibroViewController"),
                           UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "SettingsViewController")]
        
        pageController.setViewControllers([viewControllers.first!], direction: .forward, animated: false, completion: nil)
        
        addChild(pageController)
        view.addSubview(pageController.view)
        view.layoutSubviews()
        pageController.didMove(toParent: self)
        
        for subview in pageController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
        
        view.addSubview(visualEffectView)
        view.bringSubviewToFront(visualEffectView)
        view.bringSubviewToFront(blockView)
        view.bringSubviewToFront(lockButton)
        
        selectTab(index: 1)
    }
}

extension BottomNavigationViewController: SKProductsRequestDelegate {
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

extension BottomNavigationViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
}

extension BottomNavigationViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        index = indexOfViewController(viewController: viewController)
        
        if index != -1 {
            index = index - 1
        }
        
        if index < 0 {
            return nil
        } else {
            return viewControllers[index]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        index = indexOfViewController(viewController: viewController)
        
        if index != -1 {
            index = index + 1
        }
        
        if index >= viewControllers.count {
            return nil
        } else {
            return viewControllers[index]
        }
    }
}
