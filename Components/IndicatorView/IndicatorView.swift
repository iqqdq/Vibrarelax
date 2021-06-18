//
//  IndicatorView.swift
//  Curate
//
//  Created by Q on 11.05.2020.
//  Copyright © 2020 Profiteam. All rights reserved.
//

import UIKit

class IndicatorView: UIView {
    let indicator = InstagramActivityIndicator.init()
    let backgroundView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0))
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    override func draw(_ rect: CGRect) {

    }
    
    func show() {
        frame = UIScreen.main.bounds
        backgroundColor = .clear
        
        // Setup Blur Effect
        blurEffectView.frame = frame
        blurEffectView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        blurEffectView.blur.radius = 10.0
        blurEffectView.removeFromSuperview()
        addSubview(blurEffectView)
        
        // Setup Background View
        backgroundView.center = center
        backgroundView.backgroundColor = #colorLiteral(red: 0.9075601101, green: 0.2614658475, blue: 0.3625766635, alpha: 1)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.layer.cornerRadius = 10.0
        backgroundView.layer.masksToBounds = true
        
        // Setup Indicator
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: backgroundView.frame.height * 0.55, height: backgroundView.frame.height * 0.55)
        indicator.center = center
        indicator.animationDuration = 0.8
        indicator.rotationDuration = 6
        indicator.numSegments = 12
        indicator.strokeColor = #colorLiteral(red: 0.9075601101, green: 0.2614658475, blue: 0.3625766635, alpha: 1)
        indicator.lineWidth = 6.0
        addSubview(indicator)
        
        indicator.startAnimating()
        
        isUserInteractionEnabled = false
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.addSubview(self)
    }
    
    func hide() {
        if let subviews = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.subviews {
            for subview in subviews {
                if let indicatorView = subview as? IndicatorView {
                    indicatorView.removeFromSuperview()
                }
            }
        }
    }
}

