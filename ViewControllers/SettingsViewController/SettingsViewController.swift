//
//  SettingsViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 21.05.2021.
//

import UIKit
import MessageUI

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
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["vibrarelax@gmail.com"])
            present(mail, animated: true)
        }
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        let firstActivityItem = "Vibrarelax"
        let secondActivityItem: NSURL = NSURL(string: "http://your-url.com/")!
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, UIImage()], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = sender
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
        UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func openSeasonsButtonAction(_ sender: UIButton) {
        present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "OfferViewController"), animated: true, completion: nil)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
