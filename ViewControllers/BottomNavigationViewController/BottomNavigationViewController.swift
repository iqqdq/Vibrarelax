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
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var lockButton: GRButton!
    @IBOutlet weak var firstTabButton: UIButton!
    @IBOutlet weak var secondTabButton: UIButton!
    @IBOutlet weak var thirdTabButton: UIButton!
    
    var pageController: UIPageViewController!
    let modesViewConroller = ModesViewController()
    var viewControllers = [UIViewController]()
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(lockScreen), name: Notification.Name("lockscreen"), object: nil)
        
        firstTabButton.setImage(#imageLiteral(resourceName: "ic_insense_selected"), for: .selected)
        secondTabButton.setImage(#imageLiteral(resourceName: "ic_fibro_selected"), for: .selected)
        thirdTabButton.setImage(#imageLiteral(resourceName: "ic_setting_selected"), for: .selected)

        createPageViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = String()
        navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    @IBAction func blockButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.lockButton.alpha = 0.0
            self.blockView.alpha = 0.0
            self.visualEffectView.alpha = 0.0
            self.visualEffectView.blur.radius = 5.0
            self.visualEffectView.blur.tintColor = .clear
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
    
    @objc func lockScreen() {
        UIView.animate(withDuration: 0.3) {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blockView.addSubview(blurEffectView)
            self.blockView.alpha = 1.0
            self.view.bringSubviewToFront(self.blockView)
            
            self.lockButton.alpha = 1.0
            self.view.bringSubviewToFront(self.lockButton)
//            self.visualEffectView.alpha = 1.0
//            self.visualEffectView.blur.radius = 5.0
//            self.visualEffectView.blur.tintColor = .clear
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
        pageController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.delegate = self
        pageController.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pageController.view.frame = self.view.frame
            self.view.bringSubviewToFront(self.navigationBarView)
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
        view.addSubview(blockView)
        view.addSubview(lockButton)
        
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
