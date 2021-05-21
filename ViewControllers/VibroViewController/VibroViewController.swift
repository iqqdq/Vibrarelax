//
//  VibroViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 21.05.2021.
//

import UIKit
import GRView

class VibroViewController: UIViewController {
    @IBOutlet weak var switchButton: GRButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var timer: Timer?
    var interval: Float = 0.3
    var isAnimate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switchButton.setImage(#imageLiteral(resourceName: "ic_switch_off"), for: .selected)
        
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
        if sender.isSelected {
            sender.isSelected = false
            isAnimate = false
            timer?.invalidate()
        } else {
            sender.isSelected = true
            isAnimate = true
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(vibrate), userInfo: nil, repeats: true)
        }
        
        switchButton.startColor = sender.isSelected ? #colorLiteral(red: 1, green: 0.462745098, blue: 0.5490196078, alpha: 1) : #colorLiteral(red: 0.937254902, green: 0.2901960784, blue: 0.3960784314, alpha: 1)
        switchButton.endColor = sender.isSelected ? #colorLiteral(red: 0.937254902, green: 0.2901960784, blue: 0.3960784314, alpha: 1) : #colorLiteral(red: 1, green: 0.462745098, blue: 0.5490196078, alpha: 1)
        
        collectionView.reloadData()
    }
    
    @IBAction func lockButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("lockscreen"), object: nil)
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
        
        if isAnimate {
            vibroCollectionViewCell.setTimer(duration: Double((indexPath.row + 1)) * 0.050)
        } else {
            vibroCollectionViewCell.reload()
        }
        
        return vibroCollectionViewCell
    }
}

extension VibroViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30.0, height: collectionView.frame.height)
    }
}
