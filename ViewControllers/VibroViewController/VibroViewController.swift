//
//  VibroViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 21.05.2021.
//

import UIKit
import GRView

class VibroViewController: UIViewController {
    @IBOutlet weak var switchBackgroundView: GRView!
    @IBOutlet weak var switchShadowView: GRView!
    @IBOutlet weak var switchButton: GRButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pressButtonLabel: UILabel!
    @IBOutlet weak var switchButtonYConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var waveView: UIView!
    @IBOutlet weak var giftBackgroundImageView: UIImageView!
    @IBOutlet weak var giftImageView: UIImageView!
    @IBOutlet weak var offerButton: UIButton!
    
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    var timer: Timer?
    var interval: Float = 0.7
    var isAnimate: Bool = false
    var isFirstAppereance: Bool = true
    var vibroTickCount: Int = 0
    var giftTimer: Timer?
    
    let items: [String] = ["B R E E Z E",
                           "H E A R T",
                           "P U L S E",
                           "U N I V E R S E",
                           "V O L C A N O",
                           "R A I N",
                           "T O R N A D O",
                           "T S U N A M I",
                           "W A T E R F A L L",
                           "B I T",
                           "D E P T H",
                           "K A M I K A Z E"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sliderDidChangeValue), name: Notification.Name("slider_did_change_value"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSpecialOfferButton), name: Notification.Name("hide_special_offer"), object: nil)
        
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1334:
                    print("iPhone 6/6S/7/8")
                    switchButtonYConstraint.constant = 10.0
                default:
                    print("LARGE IPHONE")
                    switchButtonYConstraint.constant = 30.0
                    
            }
        }
        
        if UserDefaults.standard.bool(forKey: "is_subscribed") == true {
            giftBackgroundImageView.isHidden = true
            giftImageView.isHidden = true
            offerButton.isHidden = true
        }
        
        titleLabel.text = items[UserDefaults.standard.integer(forKey: "mode_id")]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !isAnimate {
            timer?.invalidate()
            timer = nil
        }
        
        giftTimer = nil
        giftTimer?.invalidate()
    }

    // MARK: -
    // MARK: - ACTIONS

    @IBAction func switchButtonAction(_ sender: UIButton) {
        isFirstAppereance = false
        
        if sender.isSelected {
            sender.isSelected = false
            vibroTickCount = 0
            pressButtonLabel.text = "Press the button\nto start massage"
            isAnimate = false
            timer?.invalidate()
        } else {
            sender.isSelected = true
            pressButtonLabel.text = "Press the button\nto stop massage"
            isAnimate = true
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.interval), target: self, selector: #selector(self.vibrate), userInfo: nil, repeats: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func lockButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("lockscreen"), object: nil)
    }
    
    @IBAction func noVibroButtonAction(_ sender: UIButton) {        
        NotificationCenter.default.post(name: Notification.Name("no_vibro"), object: nil)
    }
    
    @IBAction func showOfferButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("special_offer"), object: nil)
    }
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func setupLayout() {
        if UserDefaults.standard.bool(forKey: "is_subscribed") == false {
            giftBackgroundImageView.isHidden = false
            giftImageView.isHidden = false
            offerButton.isHidden = false
            
            if giftTimer == nil {
                giftTimer = Timer.scheduledTimer(timeInterval: TimeInterval(3.0), target: self, selector: #selector(self.shakeGiftImage), userInfo: nil, repeats: true)
            }
        }
        
        waveView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchBackgroundView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchShadowView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
        switchButton.setImage(#imageLiteral(resourceName: "ic_switch_on"), for: .selected)
//        switchButton.cornerRadius = switchButton.frame.height / 2
        switchBackgroundView.cornerRadius = switchBackgroundView.frame.height / 2
        switchShadowView.cornerRadius = switchShadowView.frame.height / 2
    }
    
    @objc func shakeGiftImage() {
        giftImageView.shake()
    }
    
    @objc func vibrate() {
        switch UserDefaults.standard.integer(forKey: "mode_id") {
        // HEART
        case 1:
            switch vibroTickCount {
            case 2:
                Vibration.oldSchool.vibrate()
                vibroTickCount = -1
            default:
                Vibration.heavy.vibrate()
            }
        // PULSE
        case 2:
            switch vibroTickCount {
            case 1:
                Vibration.medium.vibrate()
            case 2:
                Vibration.heavy.vibrate()
                vibroTickCount = -1
            default:
                Vibration.light.vibrate()
            }
        // UNIVERSE
        case 3:
            switch vibroTickCount {
            case 2:
                Vibration.success.vibrate()
            case 4:
                Vibration.success.vibrate()
            case 5:
                Vibration.rigid.vibrate()
                vibroTickCount = -1
            default:
                Vibration.error.vibrate()
            }
        // VOLCANO
        case 4:
            switch vibroTickCount {
            case 3:
                Vibration.oldSchool.vibrate()
                vibroTickCount = -1
            default:
                Vibration.light.vibrate()
            }
        // RAIN
        case 5:
            switch vibroTickCount {
            case 2:
                Vibration.error.vibrate()
                vibroTickCount = -1
            default:
                Vibration.warning.vibrate()
            }
        // TORNADO
        case 6:
            Vibration.oldSchool.vibrate()
            Vibration.oldSchool.vibrate()
        // TSUNAMI
        case 7:
            switch vibroTickCount {
            case 1,3,5:
                Vibration.warning.vibrate()
            case 7:
                Vibration.oldSchool.vibrate()
                vibroTickCount = -1
            default:
                Vibration.error.vibrate()
            }
        // WATERFALL
        case 8:
            switch vibroTickCount {
            case 2,6:
                Vibration.soft.vibrate()
                vibroTickCount = -1
            default:
                Vibration.error.vibrate()
            }
        // BIT
        case 9:
            switch vibroTickCount {
            case 2, 4:
                Vibration.oldSchool.vibrate()
            case 6:
                Vibration.soft.vibrate()
                vibroTickCount = -1
            default:
                Vibration.error.vibrate()
            }
        // DEPTH
        case 10:
            switch vibroTickCount {
            case 2:
                Vibration.oldSchool.vibrate()
            case 4:
                Vibration.success.vibrate()
                vibroTickCount = -1
            default:
                Vibration.soft.vibrate()
            }
        // KAMIKAZE
        case 11:
            switch vibroTickCount {
            case 4:
                Vibration.oldSchool.vibrate()
                vibroTickCount = -1
            default:
                Vibration.error.vibrate()
            }
        // BREEZE
        default:
            switch vibroTickCount {
            case 3:
                Vibration.oldSchool.vibrate()
                vibroTickCount = -1
            default:
                Vibration.error.vibrate()
                Vibration.error.vibrate()
            }
        }
        
        vibroTickCount += 1
    }
    
    @objc func sliderDidChangeValue(notification: NSNotification) {
        if let sliderValue = notification.userInfo?["slider_value"] as? Float {
            if sliderValue == 0.0 {
                timer?.invalidate()
            }
                
            if sliderValue > 0.0 && sliderValue < 0.25 {
                interval = 1.5
                if ((timer?.isValid) != nil) {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(vibrate), userInfo:nil, repeats: true)
                }
            }
            
            if sliderValue > 0.25 && sliderValue < 0.5 {
                interval = 1.2
                if ((timer?.isValid) != nil) {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(vibrate), userInfo:nil, repeats: true)
                }
            }
            
            if sliderValue > 0.5 && sliderValue < 0.75 {
                interval = 0.9
                if ((timer?.isValid) != nil) {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(vibrate), userInfo:nil, repeats: true)
                }
            }
            
            if sliderValue > 0.75 && sliderValue < 1.0 {
                interval = 0.6
                if ((timer?.isValid) != nil) {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(vibrate), userInfo:nil, repeats: true)
                }
            }
            
            if sliderValue == 1.0 {
                interval = 0.3
                if ((timer?.isValid) != nil) {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(vibrate), userInfo:nil, repeats: true)
                }
            }
        }
    }
    
    @objc func hideSpecialOfferButton() {
        giftBackgroundImageView.isHidden = true
        giftImageView.isHidden = true
        offerButton.isHidden = true
    }
}

extension VibroViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let vibroCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VibroCollectionViewCell", for: indexPath as IndexPath) as! VibroCollectionViewCell
        
        if !isFirstAppereance {
            if isAnimate {
                vibroCollectionViewCell.setTimer(duration: Double(indexPath.row) * 0.05)
            } else {
                vibroCollectionViewCell.reload()
            }
        }
        
        return vibroCollectionViewCell
    }
}

extension VibroViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 26.0, height: collectionView.frame.height)
    }
}
