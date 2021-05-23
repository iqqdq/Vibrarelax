//
//  VibroCollectionViewCell.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 21.05.2021.
//

import UIKit
import GRView

class VibroCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: GRView!
    
    var step: CGFloat = 25.0
    var time: TimeInterval = TimeInterval(Double.random(in: 0.3...0.45))
    var timer: Timer?
 
    func setTimer(duration: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.step = CGFloat(Double.random(in: 20.0...25.0))
            self.time = TimeInterval(Double.random(in: 0.15...0.3))
            self.timer = Timer.scheduledTimer(timeInterval: self.time, target: self, selector: #selector(self.animate), userInfo: nil, repeats: true)
        }
    }
    
    func reload() {
        timer?.invalidate()
        
        indicatorView.startColor = #colorLiteral(red: 0.9529411765, green: 0.7960784314, blue: 0.7294117647, alpha: 1)
        indicatorView.endColor = #colorLiteral(red: 0.7607843137, green: 0.6274509804, blue: 0.5882352941, alpha: 1)
        
        UIView.animate(withDuration: 0.3) {
            self.topConstraint.constant = 25.0
            self.bottomConstraint.constant = 25.0
            self.layoutIfNeeded()
        }
    }
    
    @objc func animate() {
        indicatorView.startColor = #colorLiteral(red: 1, green: 0.462745098, blue: 0.5490196078, alpha: 1)
        indicatorView.endColor = #colorLiteral(red: 0.937254902, green: 0.2901960784, blue: 0.3960784314, alpha: 1)
        
        UIView.animate(withDuration: 0.3) {
            if (self.topConstraint.constant == self.step) {
                self.topConstraint.constant = 0.0
                self.bottomConstraint.constant = 0.0
            } else {
                self.topConstraint.constant = self.step
                self.bottomConstraint.constant = self.step
            }
            
            self.layoutIfNeeded()
        }
    }
}
