//
//  VibroSheetViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 21.05.2021.
//

import UIKit

class VibroSheetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
