//
//  SettingsViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 21.05.2021.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func noVibroButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("no_vibro"), object: nil)
    }
    
    @IBAction func rateButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction func reviewButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction func openSeasonsButtonAction(_ sender: UIButton) {
        present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "OfferViewController"), animated: true, completion: nil)
    }
}
