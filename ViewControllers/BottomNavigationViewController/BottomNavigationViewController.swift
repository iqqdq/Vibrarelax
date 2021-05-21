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
    @IBOutlet weak var countdownLabelView: UIView!
    @IBOutlet weak var offerViewBottomConstraint: NSLayoutConstraint!
    
    var pageController: UIPageViewController!
    let modesViewConroller = ModesViewController()
    var viewControllers = [UIViewController]()
    var index = Int()
    var visualEffectView: UIVisualEffectView?
    var timer: Timer?
    var isLocked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(lockScreen), name: Notification.Name("lockscreen"), object: nil)
        
        setupLockView()
        createPageViewController()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showOfferView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = String()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        DispatchQueue.main.async {
            self.offerBackgroundView.roundCorners([.topLeft, .topRight], radius: 40.0)
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
    
    @IBAction func tabButtonAction(_ sender: UIButton) {
        selectTab(index: sender.tag)
    }
    
    @IBAction func lockButtonTouchDownAction(_ sender: UIButton) {
        if isLocked {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(1.75), target: self, selector: #selector(unlockScreen), userInfo: nil, repeats: false)
        } else {
            UIView.animate(withDuration: 0.3) {
                self.lockButton.alpha = 0.0
                self.blockView.alpha = 0.0
                self.visualEffectView?.alpha = 0.0
            }
        }
    }
    
    @IBAction func lockButtonTouchUpInsideAction(_ sender: UIButton) {
        timer?.invalidate()
    }
    @IBAction func lockButtonTouchUpOutsideAction(_ sender: UIButton) {
        timer?.invalidate()
    }
    
    @IBAction func offerButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.offerViewBottomConstraint.constant = -600.0
            self.view.layoutSubviews()
        } completion: { (finish) in
            self.showSheetController(viewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "OfferViewController"), sizes: [.fullscreen])
        }
    }
    
    @IBAction func closeOfferButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.offerViewBottomConstraint.constant = -600.0
            self.view.layoutSubviews()
        }
    }
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func selectTab(index: Int) {
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
    
    func setupLockView() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView?.frame = UIScreen.main.bounds
        visualEffectView?.blur.radius = 5.0
        visualEffectView?.blur.tintColor = .clear
        visualEffectView?.alpha = 0.0
    }
    
    func showOfferView() {
        let countdownLabel = CountdownLabel(frame: CGRect(x: (UIScreen.main.bounds.width / 2 - 150.0), y: 0.0, width: UIScreen.main.bounds.width - 80.0, height: 44.0), minutes: 60*60)
        countdownLabel.animationType = .Evaporate
        countdownLabel.timeFormat = "hh:mm:ss"
        countdownLabel.font = UIFont.init(name: "Nunito-SemiBold", size: 52.0)
        countdownLabel.textColor = #colorLiteral(red: 0.937254902, green: 0.2901960784, blue: 0.3960784314, alpha: 1)
        countdownLabelView.addSubview(countdownLabel)
        countdownLabel.start()
        
        UIView.animate(withDuration: 0.3) {
            self.offerViewBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
        }
    }
    
    @objc func lockScreen() {
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView?.alpha = 1.0
            self.view.bringSubviewToFront(self.visualEffectView!)
            
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
            self.visualEffectView?.alpha = 0.0
            self.blockView.alpha = 0.0
            self.lockButton.alpha = 0.0
        } completion: { (finish) in
            self.isLocked = true
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
        
        view.addSubview(visualEffectView!)
        view.bringSubviewToFront(visualEffectView!)
        view.bringSubviewToFront(blockView)
        view.bringSubviewToFront(lockButton)
        view.bringSubviewToFront(countdownLabelView)
        
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
