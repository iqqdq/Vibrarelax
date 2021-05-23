//
//  ModesViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 20.05.2021.
//

import UIKit

class ModesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var levelImageView: UIImageView!
    
    let items: [[String : String]] = [["Бриз" : "ic_breeze"],
                                      ["Сердце" : "ic_heart"],
                                      ["Импульс" : "ic_impulse"],
                                      ["Вселенная" : "ic_hurricane"],
                                      ["Вулкан" : "ic_volcano"],
                                      ["Дождь" : "ic_rain"],
                                      ["Торнадо" : "ic_tornado"],
                                      ["Цунами" : "ic_tsunami"],
                                      ["Водопад" : "ic_waterfall"],
                                      ["Бит" : "ic_bit"],
                                      ["Глубина" : "ic_depth"],
                                      ["Камикатдзе" : "ic_kamikaze"]]
    var selectedIndexes: [Int] = [0]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        levelImageView.image = levelImageView.image?.withRenderingMode(.alwaysTemplate)
        levelImageView.tintColor = #colorLiteral(red: 0.7411764706, green: 0.5960784314, blue: 0.5254901961, alpha: 0.7)
    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "slider_did_change_value"),
                                        object: nil,
                                        userInfo: ["slider_value": sender.value])
    }
}

extension ModesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let modeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModeCollectionViewCell", for: indexPath as IndexPath) as! ModeCollectionViewCell
        modeCollectionViewCell.backgroundView?.layer.cornerRadius = modeCollectionViewCell.containerView.frame.height / 2
        
        let item = items[indexPath.row];
        for (key, value) in item {
            modeCollectionViewCell.titleLabel.text = key
            modeCollectionViewCell.modeImageView.image = UIImage.init(named: value)
        }
        
        switch indexPath.row {
        case 1:
            modeCollectionViewCell.widthConstraint.constant = 32.0
            modeCollectionViewCell.heightConstraint.constant = 28.0
        case 2:
            modeCollectionViewCell.widthConstraint.constant = 40.0
            modeCollectionViewCell.heightConstraint.constant = 30.0
        case 3:
            modeCollectionViewCell.widthConstraint.constant = 42.0
            modeCollectionViewCell.heightConstraint.constant = 42.0
        case 4:
            modeCollectionViewCell.widthConstraint.constant = 40.0
            modeCollectionViewCell.heightConstraint.constant = 50.0
        case 5:
            modeCollectionViewCell.widthConstraint.constant = 34.0
            modeCollectionViewCell.heightConstraint.constant = 34.0
        case 6:
            modeCollectionViewCell.widthConstraint.constant = 31.0
            modeCollectionViewCell.heightConstraint.constant = 34.0
        case 7:
            modeCollectionViewCell.widthConstraint.constant = 32.0
            modeCollectionViewCell.heightConstraint.constant = 32.0
        case 8:
            modeCollectionViewCell.widthConstraint.constant = 32.0
            modeCollectionViewCell.heightConstraint.constant = 32.0
        case 9:
            modeCollectionViewCell.widthConstraint.constant = 42.0
            modeCollectionViewCell.heightConstraint.constant = 45.0
        case 10:
            modeCollectionViewCell.widthConstraint.constant = 32.0
            modeCollectionViewCell.heightConstraint.constant = 38.0
        case 11:
            modeCollectionViewCell.widthConstraint.constant = 38.0
            modeCollectionViewCell.heightConstraint.constant = 36.0
        default:
            modeCollectionViewCell.widthConstraint.constant = 38.0
            modeCollectionViewCell.heightConstraint.constant = 32.0
        }
        
        if selectedIndexes.contains(indexPath.row) {
            modeCollectionViewCell.containerView.startColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            modeCollectionViewCell.containerView.endColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            modeCollectionViewCell.containerView.borderWidth = 2.0
            modeCollectionViewCell.containerView.borderColor = #colorLiteral(red: 0.9294117647, green: 0.5176470588, blue: 0.5843137255, alpha: 1)
            modeCollectionViewCell.containerView.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
            modeCollectionViewCell.containerView.shadowRadius = 8.0
            modeCollectionViewCell.containerView.shadowOffset = CGSize(width: 5.0, height: 5.0)
            modeCollectionViewCell.containerView.shadowOpacity = 1.0
            modeCollectionViewCell.modeImageView.image = modeCollectionViewCell.modeImageView.image?.withRenderingMode(.alwaysOriginal)
        } else {
            modeCollectionViewCell.containerView.startColor = #colorLiteral(red: 0.8466313481, green: 0.6986467838, blue: 0.6219901443, alpha: 1)
            modeCollectionViewCell.containerView.endColor = #colorLiteral(red: 0.9058823529, green: 0.7960784314, blue: 0.7529411765, alpha: 1)
            modeCollectionViewCell.containerView.borderWidth = 0.0
            modeCollectionViewCell.containerView.shadowOpacity = 0.0
            modeCollectionViewCell.modeImageView.image = modeCollectionViewCell.modeImageView.image?.withRenderingMode(.alwaysTemplate)
            modeCollectionViewCell.modeImageView.tintColor = #colorLiteral(red: 0.7607843137, green: 0.6274509804, blue: 0.5882352941, alpha: 1)
        }

        return modeCollectionViewCell
    }
}

extension ModesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexes.contains(indexPath.row) {
            selectedIndexes = selectedIndexes.filter { $0 != indexPath.row }
        } else {
            selectedIndexes.append(indexPath.row)
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height / 4)
    }
}
