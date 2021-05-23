//
//  OfferViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 22.05.2021.
//

import UIKit

class OfferViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: -
    // MARK: - ACTIONS

    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func privacyButtonAction(_ sender: UIButton) {
        showSheetController(viewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "PrivacySheetViewController"), sizes: [.fixed(UIScreen.main.bounds.height / 1.5)])
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
            offerCollectionViewCell.topLabel.text = "35% СКИДКА"
            offerCollectionViewCell.titleLabel.text = "Каждый\nмесяц"
            offerCollectionViewCell.priceLabel.text = "1550 ₽ / \nеженедельно"
        case 2:
            offerCollectionViewCell.topLabel.text = "ЛУЧШАЯ ЦЕНА"
            offerCollectionViewCell.titleLabel.text = "Каждый\nгод"
            offerCollectionViewCell.priceLabel.text = "3990 ₽ / \nеженедельно"
        default:
            offerCollectionViewCell.topLabel.text = "ПОПУЛЯРНЫЙ"
            offerCollectionViewCell.titleLabel.text =  "Каждую\nнеделю"
            offerCollectionViewCell.priceLabel.text = "499 ₽ / \nеженедельно"
        }
        
        if indexPath.row == selectedIndex {
            offerCollectionViewCell.containerView.startColor = #colorLiteral(red: 0.9882352941, green: 0.3333333333, blue: 0.431372549, alpha: 1)
            offerCollectionViewCell.containerView.endColor = #colorLiteral(red: 0.9882352941, green: 0.3333333333, blue: 0.431372549, alpha: 1)
            
            offerCollectionViewCell.topLabelView.startColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            offerCollectionViewCell.topLabelView.endColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            offerCollectionViewCell.bottomView.startColor = #colorLiteral(red: 0.9333333333, green: 0.2823529412, blue: 0.3647058824, alpha: 1)
            offerCollectionViewCell.bottomView.endColor = #colorLiteral(red: 0.9333333333, green: 0.2823529412, blue: 0.3647058824, alpha: 1)
            
            offerCollectionViewCell.titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            offerCollectionViewCell.containerView.startColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            offerCollectionViewCell.containerView.endColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            offerCollectionViewCell.topLabelView.startColor = #colorLiteral(red: 0.9019607843, green: 0.7450980392, blue: 0.6666666667, alpha: 1)
            offerCollectionViewCell.topLabelView.endColor = #colorLiteral(red: 0.9019607843, green: 0.7450980392, blue: 0.6666666667, alpha: 1)
            
            offerCollectionViewCell.bottomView.startColor = #colorLiteral(red: 0.9882352941, green: 0.9019607843, blue: 0.8588235294, alpha: 1)
            offerCollectionViewCell.bottomView.endColor = #colorLiteral(red: 0.9882352941, green: 0.9019607843, blue: 0.8588235294, alpha: 1)
            
            offerCollectionViewCell.titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
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
