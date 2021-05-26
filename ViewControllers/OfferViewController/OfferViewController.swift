//
//  OfferViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 22.05.2021.
//

import UIKit
import GRView

class OfferViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var policyView: GRView!
    @IBOutlet weak var termsView: GRView!
    @IBOutlet weak var privacyViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lipsImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBlurView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.policyView.roundCorners([.topLeft, .topRight], radius: 30.0)
            self.termsView.roundCorners([.topLeft, .topRight], radius: 30.0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("default_slider_value"), object: nil)
    }
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func setupBlurView() {
        visualEffectView.frame = UIScreen.main.bounds
        visualEffectView.blur.radius = 4.0
        visualEffectView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        visualEffectView.alpha = 0.0
        view.addSubview(visualEffectView)
        view.bringSubviewToFront(policyView)
        view.bringSubviewToFront(termsView)
    }
    
    // MARK: -
    // MARK: - ACTIONS

    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        
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

extension OfferViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let offerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell", for: indexPath as IndexPath) as! OfferCollectionViewCell
        offerCollectionViewCell.topLabelView.transform = CGAffineTransform(rotationAngle: -(.pi / 10))
        
        switch indexPath.row {
        case 1:
            offerCollectionViewCell.topLabel.text = "35% DISCOUNT"
            offerCollectionViewCell.titleLabel.text = "Every\nmonth"
            offerCollectionViewCell.priceLabel.text = "25 $ / \nmonthly"
        case 2:
            offerCollectionViewCell.topLabel.text = "BEST PRICE"
            offerCollectionViewCell.titleLabel.text = "Every\nyear"
            offerCollectionViewCell.priceLabel.text = "79 $ / \nannually"
        default:
            offerCollectionViewCell.topLabel.text = "POPULAR"
            offerCollectionViewCell.titleLabel.text =  "Every\nweek"
            offerCollectionViewCell.priceLabel.text = "9 $ / \nweekly"
        }
        
        if indexPath.row == selectedIndex {
            offerCollectionViewCell.centerImageView.image = #imageLiteral(resourceName: "ic_done_white")
            
            offerCollectionViewCell.containerView.startColor = #colorLiteral(red: 0.9882352941, green: 0.3333333333, blue: 0.431372549, alpha: 1)
            offerCollectionViewCell.containerView.endColor = #colorLiteral(red: 0.9882352941, green: 0.3333333333, blue: 0.431372549, alpha: 1)
            
            offerCollectionViewCell.topLabelView.startColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            offerCollectionViewCell.topLabelView.endColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            offerCollectionViewCell.bottomView.startColor = #colorLiteral(red: 0.9333333333, green: 0.2823529412, blue: 0.3647058824, alpha: 1)
            offerCollectionViewCell.bottomView.endColor = #colorLiteral(red: 0.9333333333, green: 0.2823529412, blue: 0.3647058824, alpha: 1)
            
            offerCollectionViewCell.titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            offerCollectionViewCell.centerImageView.image = #imageLiteral(resourceName: "ic_done_bronze")
            
            offerCollectionViewCell.containerView.startColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            offerCollectionViewCell.containerView.endColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            offerCollectionViewCell.topLabelView.startColor = #colorLiteral(red: 0.9019607843, green: 0.7450980392, blue: 0.6666666667, alpha: 1)
            offerCollectionViewCell.topLabelView.endColor = #colorLiteral(red: 0.9019607843, green: 0.7450980392, blue: 0.6666666667, alpha: 1)
            
            offerCollectionViewCell.bottomView.startColor = #colorLiteral(red: 0.9882352941, green: 0.9019607843, blue: 0.8588235294, alpha: 1)
            offerCollectionViewCell.bottomView.endColor = #colorLiteral(red: 0.9882352941, green: 0.9019607843, blue: 0.8588235294, alpha: 1)
            
            offerCollectionViewCell.titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1334:
                print("iPhone 6/6S/7/8")
                lipsImageViewTopConstraint.constant = -8.0
                collectionViewTopConstraint.constant = 12.0
            default:
                print("")
            }
        }
        
        return offerCollectionViewCell
    }
}

extension OfferViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 20.0 - 44.0) / 3
        return CGSize(width: width, height: collectionView.frame.height)
    }
}
