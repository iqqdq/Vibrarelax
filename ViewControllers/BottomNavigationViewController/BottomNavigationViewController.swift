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

class BottomNavigationViewController: UIViewController {
    @IBOutlet weak var navigationBarView: GRView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var lockButton: GRButton!
    @IBOutlet weak var firstTabButton: UIButton!
    @IBOutlet weak var secondTabButton: UIButton!
    @IBOutlet weak var thirdTabButton: UIButton!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var offerBackgroundView: UIView!
    @IBOutlet weak var countdouwnLabel: UILabel!
    @IBOutlet weak var offerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var openSeasonsButton: GRButton!
    @IBOutlet weak var unlockImageView: UIImageView!
    @IBOutlet weak var noVibroView: GRView!
    @IBOutlet weak var noVibroBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockImageHeightConstraint: NSLayoutConstraint!
    
    var pageController: UIPageViewController!
    let modesViewConroller = ModesViewController()
    var viewControllers = [UIViewController]()
    var index = Int()
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var lockTimer: Timer?
    var isLocked: Bool = false
    var countdownTimer: Timer?
    var count: Int = 59
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(lockScreen), name: Notification.Name("lockscreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNoVibroView), name: Notification.Name("no_vibro"), object: nil)
        
        createPageViewController()
        setupBlur()
        showOfferView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = String()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        DispatchQueue.main.async {
            self.offerViewBottomConstraint.constant = -1000.0
            self.offerBackgroundView.roundCorners([.topLeft, .topRight], radius: 40.0)
        }
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1334:
                    print("iPhone 6/6S/7/8")
                    self.unlockImageHeightConstraint.constant = 330.0
                default:
                    print("SMALL IPHONE")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false  
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
            self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "OfferViewController"), animated: true, completion: nil)
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
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func selectTab(index: Int) {
        openSeasonsButton.isHidden = index == 0 ? false : true
        unlockImageView.isHidden = index == 0 ? false : true
        
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
    
    func setupBlur() {
        visualEffectView.frame = UIScreen.main.bounds
        visualEffectView.blur.radius = 15.0
        visualEffectView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        visualEffectView.alpha = 0.0
        view.bringSubviewToFront(visualEffectView)
    }
    
    func showOfferView() {
        countdownTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self, selector: #selector(countdouwn), userInfo: nil, repeats: true)
        
        view.bringSubviewToFront(offerView)
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIView.animate(withDuration: 0.5) {
                self.visualEffectView.alpha = 1.0
                self.offerViewBottomConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            }
        }
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
        count -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.countdouwnLabel.text = String(self.count).count > 1 ? "\(self.count)" : "0\(self.count)"
        }
        
        if count == 0 {
            countdownTimer?.invalidate()
            UIView.animate(withDuration: 0.3) {
                self.visualEffectView.alpha = 0.0
                self.offerViewBottomConstraint.constant = -600.0
                self.view.layoutIfNeeded()
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
            self.view.bringSubviewToFront(self.offerView)
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
        
        selectTab(index: 0)
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
