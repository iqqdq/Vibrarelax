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
    
    var timer: Timer?
    var interval: Float = 0.7
    var isAnimate: Bool = false
    var isFirstAppereance: Bool = true
    var vibroTickCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switchButton.setImage(#imageLiteral(resourceName: "ic_switch_on"), for: .selected)
        switchButton.cornerRadius = switchButton.frame.height / 2
        switchBackgroundView.cornerRadius = switchButton.cornerRadius
        switchShadowView.cornerRadius = switchButton.cornerRadius
        
        NotificationCenter.default.addObserver(self, selector: #selector(sliderDidChangeValue), name: Notification.Name("slider_did_change_value"), object: nil)
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
        
        waveView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchBackgroundView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchShadowView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
        switch UserDefaults.standard.integer(forKey: "mode_id") {
        case 1:
            titleLabel.text = "H E A R T"
        default:
            titleLabel.text = "B R E E Z E"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !isAnimate {
            timer?.invalidate()
            timer = nil
        }
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
            pressButtonLabel.text = "Press the button\nto stop the massage"
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
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    @objc func vibrate() {
        if UserDefaults.standard.integer(forKey: "mode_id") == 1 {
            switch vibroTickCount {
            case 1:
                Vibration.heavy.vibrate()
            case 3:
                Vibration.heavy.vibrate()
                vibroTickCount = -1
            default:
                Vibration.oldSchool.vibrate()
            }
        } else {
            switch vibroTickCount {
            case 3:
                Vibration.oldSchool.vibrate()
                vibroTickCount = -1
            default:
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
