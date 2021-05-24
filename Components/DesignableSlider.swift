//
//  DesignableSlider.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 24.05.2021.
//

import UIKit
@IBDesignable open class DesignableSlider: UISlider {

    @IBInspectable var trackHeight: CGFloat = 5

    @IBInspectable var roundImage: UIImage? {
        didSet{
            setThumbImage(roundImage, for: .normal)
        }
    }
    
    @IBInspectable var roundHighlightedImage: UIImage? {
        didSet{
            setThumbImage(roundHighlightedImage, for: .highlighted)
        }
    }
    
    @IBInspectable open var trackWidth: CGFloat = 20.0 {
            didSet {
                setNeedsDisplay()
            }
        }

        override open func trackRect(forBounds bounds: CGRect) -> CGRect {
            let defaultBounds = super.trackRect(forBounds: bounds)
            return CGRect(
                x: defaultBounds.origin.x,
                y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
                width: defaultBounds.size.width,
                height: trackWidth
            )
        }
}
