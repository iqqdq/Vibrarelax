//
//  BottomNavigationViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 20.05.2021.
//

import UIKit
import FittedSheets
import GRView

class BottomNavigationViewController: UIViewController {
    @IBOutlet weak var navigationBarView: GRView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    var pageController: UIPageViewController!
    var viewControllers = [UIViewController(), UIViewController(), UIViewController(), UIViewController()]
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
