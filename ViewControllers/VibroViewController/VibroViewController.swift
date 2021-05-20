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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switchButton.setImage(#imageLiteral(resourceName: "ic_switch_off"), for: .selected)
    }
    

    // MARK: -
    // MARK: - ACTIONS

    @IBAction func switchButtonAction(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
        
        switchButton.startColor = sender.isSelected ? #colorLiteral(red: 1, green: 0.462745098, blue: 0.5490196078, alpha: 1) : #colorLiteral(red: 0.937254902, green: 0.2901960784, blue: 0.3960784314, alpha: 1)
        switchButton.endColor = sender.isSelected ? #colorLiteral(red: 0.937254902, green: 0.2901960784, blue: 0.3960784314, alpha: 1) : #colorLiteral(red: 1, green: 0.462745098, blue: 0.5490196078, alpha: 1)
    }
    
    @IBAction func lockButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("lockscreen"), object: nil)
    }
    
}
