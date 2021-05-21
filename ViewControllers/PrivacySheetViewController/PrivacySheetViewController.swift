//
//  PrivacySheetViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 22.05.2021.
//

import UIKit

class PrivacySheetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -
    // MARK: - ACTIONS

     @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
     }
}
