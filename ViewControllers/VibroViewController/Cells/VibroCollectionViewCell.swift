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
    
    let height: CGFloat = 94.0
    let circleHeight: CGFloat = 28.0
    let step: CGFloat = 38.0
    var timer: Timer?
 
    func setTimer(duration: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.animate), userInfo: nil, repeats: true)
        }
    }
    
    func reload() {
        timer?.invalidate()
        
        indicatorView.startColor = #colorLiteral(red: 0.9529411765, green: 0.7960784314, blue: 0.7294117647, alpha: 1)
        indicatorView.endColor = #colorLiteral(red: 0.7607843137, green: 0.6274509804, blue: 0.5882352941, alpha: 1)
        
        UIView.animate(withDuration: 0.3) {
            self.topConstraint.constant = self.step
            self.bottomConstraint.constant = self.step
            
            self.layoutSubviews()
            self.layoutIfNeeded()
        }
    }
    
    @objc func animate() {
        indicatorView.startColor = #colorLiteral(red: 1, green: 0.462745098, blue: 0.5490196078, alpha: 1)
        indicatorView.endColor = #colorLiteral(red: 0.937254902, green: 0.2901960784, blue: 0.3960784314, alpha: 1)
        
        UIView.animate(withDuration: 0.15) {
            if (self.topConstraint.constant == self.step) {
                self.topConstraint.constant = 0.0
                self.bottomConstraint.constant = 0.0
            } else {
                self.topConstraint.constant = self.step
                self.bottomConstraint.constant = self.step
            }
            
            self.layoutSubviews()
            self.layoutIfNeeded()
        }
    }
}
