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
    @IBOutlet weak var switchButton: GRButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var timer: Timer?
    var interval: Float = 0.5
    var isAnimate: Bool = false
    var isFirstAppereance: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switchButton.setImage(#imageLiteral(resourceName: "ic_switch_on"), for: .selected)
        switchButton.cornerRadius = switchButton.frame.height / 2
        switchBackgroundView.cornerRadius = switchButton.cornerRadius
        
        NotificationCenter.default.addObserver(self, selector: #selector(sliderDidChangeValue), name: Notification.Name("slider_did_change_value"), object: nil)
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
            self.isAnimate = false
            self.timer?.invalidate()
        } else {
            sender.isSelected = true
            self.isAnimate = true
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.interval), target: self, selector: #selector(self.vibrate), userInfo: nil, repeats: true)
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
        Vibration.success.vibrate()
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
