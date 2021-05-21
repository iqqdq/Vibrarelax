//
//  Extensioons.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 21.05.2021.
//

import UIKit
import FittedSheets

extension UIViewController {
    func showSheetController(viewController: UIViewController, sizes: [SheetSize]) {
        var options = SheetOptions()
        options.pullBarHeight = 16.0
        options.shouldExtendBackground = false
        options.useFullScreenMode = false
        
        let sheetController = SheetViewController(controller: viewController, sizes: sizes, options: options)
        sheetController.treatPullBarAsClear = true
        sheetController.cornerRadius = 20.0
        sheetController.gripSize = CGSize(width: 56.0, height: 6.0)
        present(sheetController, animated: true, completion: nil)

        for subview in viewController.view.subviews {
            if subview is UITableView {
                sheetController.handleScrollView(subview as! UIScrollView)
            }
        }
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }

}
