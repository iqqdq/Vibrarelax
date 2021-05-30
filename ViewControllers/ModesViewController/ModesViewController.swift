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
    @IBOutlet weak var designableSlider: DesignableSlider!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    let items: [[String : String]] = [["Breeze" : "ic_breeze"],
                                      ["Heart" : "ic_heart"],
                                      ["Pulse" : "ic_impulse"],
                                      ["Universe" : "ic_hurricane"],
                                      ["Volcano" : "ic_volcano"],
                                      ["Rain" : "ic_rain"],
                                      ["Tornado" : "ic_tornado"],
                                      ["Tsunami" : "ic_tsunami"],
                                      ["Waterfall" : "ic_waterfall"],
                                      ["Bit" : "ic_bit"],
                                      ["Depth" : "ic_depth"],
                                      ["Kamikaze" : "ic_kamikaze"]]
    var selectedIndexes: [Int] = [0, 1]
    var selectedIndex: Int = 0
    var isIphone8: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        levelImageView.image = levelImageView.image?.withRenderingMode(.alwaysTemplate)
        levelImageView.tintColor = #colorLiteral(red: 0.7411764706, green: 0.5960784314, blue: 0.5254901961, alpha: 0.7)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultSliderValue), name: Notification.Name("default_slider_value"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unlockModes), name: Notification.Name("show_all_modes"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1334:
                print("iPhone 6/6S/7/8")
                isIphone8 = true
                collectionViewBottomConstraint.constant = 60.0
                collectionView.isScrollEnabled = true
                collectionView.alwaysBounceVertical = true
            default:
                print("Unknown")
            }
        }
    }
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    @objc func setDefaultSliderValue() {
        designableSlider.value = 0.3
    }
    
    @objc func unlockModes() {
        selectedIndexes.removeAll()
        
        var index = 0
        for _ in items {
            selectedIndexes.append(index)
            index += 1
        }
        
        print("ALLOWED MODES INDEXES: \(selectedIndexes)")
        collectionView.reloadData()
    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        if UserDefaults.standard.bool(forKey: "is_subscribed") == true {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "slider_did_change_value"),
                                            object: nil,
                                            userInfo: ["slider_value": sender.value])
        } else {
            if sender.value > 0.4 {
                sender.value = 0.4
                present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "OfferViewController"), animated: true, completion: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "slider_did_change_value"),
                                                object: nil,
                                                userInfo: ["slider_value": sender.value])
            }
        }
    }
}

extension ModesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isIphone8 ? items.count + 1 : items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let modeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModeCollectionViewCell", for: indexPath as IndexPath) as! ModeCollectionViewCell
        modeCollectionViewCell.backgroundView?.layer.cornerRadius = modeCollectionViewCell.containerView.frame.height / 2
        
        if isIphone8 && indexPath.row == items.count {
            modeCollectionViewCell.containerView.isHidden = true
            modeCollectionViewCell.titleLabel.isHidden = true
            return modeCollectionViewCell
        }
        
        let item = items[indexPath.row];
        for (key, value) in item {
            modeCollectionViewCell.titleLabel.text = key
            modeCollectionViewCell.modeImageView.image = UIImage.init(named: value)
        }
        
        switch indexPath.row {
        case 1:
            modeCollectionViewCell.modeImageViewYConstraint.constant = 3.0
            modeCollectionViewCell.widthConstraint.constant = 34.0
            modeCollectionViewCell.heightConstraint.constant = 30.0
        case 2:
            modeCollectionViewCell.modeImageViewYConstraint.constant = -1.0
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
        
        if selectedIndex == indexPath.row {
            modeCollectionViewCell.containerView.borderWidth = 2.0
            modeCollectionViewCell.containerView.borderColor = #colorLiteral(red: 0.9294117647, green: 0.5176470588, blue: 0.5843137255, alpha: 1)
        } else {
            modeCollectionViewCell.containerView.borderWidth = 0.0
        }
        
        if selectedIndexes.contains(indexPath.row) {
            modeCollectionViewCell.modeBackgroundImageView.isHidden = true
            modeCollectionViewCell.containerView.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
            modeCollectionViewCell.containerView.shadowRadius = 8.0
            modeCollectionViewCell.containerView.shadowOffset = CGSize(width: 5.0, height: 5.0)
            modeCollectionViewCell.containerView.shadowOpacity = 1.0
            modeCollectionViewCell.modeImageView.image = modeCollectionViewCell.modeImageView.image?.withRenderingMode(.alwaysOriginal)
        } else {
            modeCollectionViewCell.modeBackgroundImageView.isHidden = false
            modeCollectionViewCell.containerView.borderWidth = 0.0
            modeCollectionViewCell.containerView.shadowOpacity = 0.0
            modeCollectionViewCell.modeImageView.image = modeCollectionViewCell.modeImageView.image?.withRenderingMode(.alwaysTemplate)
            modeCollectionViewCell.modeImageView.tintColor = #colorLiteral(red: 0.7607843137, green: 0.6274509804, blue: 0.5882352941, alpha: 1)
        }
        
        if isIphone8 {
            modeCollectionViewCell.titleLabel.font = UIFont.init(name: "Nunito-SemiBold", size: 14.0)
        }

        return modeCollectionViewCell
    }
}

extension ModesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexes.contains(indexPath.row) {
            UserDefaults.standard.setValue(indexPath.row, forKey: "mode_id")
            selectedIndex = indexPath.row
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: isIphone8 && indexPath.row == items.count ?  collectionView.frame.height / 6  : collectionView.frame.height / 4)
    }
}
