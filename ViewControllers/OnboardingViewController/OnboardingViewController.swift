//
//  OnboardingViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 20.05.2021.
//

import UIKit
import GRView

class OnboardingViewController: UIViewController {
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: GRButton!
    @IBOutlet weak var secondIndicatorView: UIView!
    @IBOutlet weak var thirdIndicatorView: UIView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    let items: [[String : String]] = [["Welcome\nto Vibrarelax" : "The massage is relaxing. 60 minutes of good massage has the same effect on your body as 7-8 hours of good sleep."],
                                      ["Enjoy strong\nvibration" : "Did you know that there are approximately 5 million receptors on our skin, with only 3000 on one fingertip?"],
                                      ["Try with\nall modes PRO" : "9 vibration modes, 5 speed modes, no ads, weekly content\nupdate for $ 9 / week."]]
    let images: [String] = ["ic_onboarding_first", "ic_onboarding_second", "ic_onboarding_third"]
    var timer: Timer?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWaveAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        if sender.tag == 2 {
            UserDefaults.standard.setValue(true, forKey: "onboarding")
            navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "BottomNavigationViewController"), animated: true)
        } else {
            collectionView.scrollToItem(at: IndexPath(item: sender.tag + 1, section: 0), at: .centeredHorizontally, animated: true)
            sender.tag += 1
        }
        
        updateIndicator()
    }
    
    @IBAction func restoreButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        UserDefaults.standard.setValue(true, forKey: "onboarding")
        navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "BottomNavigationViewController"), animated: true)
    }
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func setupWaveAnimations() {
        let topWave = Wave(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2))
        topWave.direction = .right
        topWave.waveHeight = 100
        topWave.waveTop    = 0.5
        topWave.variance   = 50
        topWave.fps        = 80
        topWave.fillColor = #colorLiteral(red: 0.9294117647, green: 0.2666666667, blue: 0.3647058824, alpha: 1)
        topWave.backgroundColor = .clear
        topWave.waveWidth  = UIScreen.main.bounds.width * 1.5
        topWave.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        view.addSubview(topWave)
        
        let botWave = Wave(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.height - (UIScreen.main.bounds.height / 4), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 4))
        botWave.direction = .right
        botWave.waveHeight = 100
        botWave.waveTop    = 0.5
        botWave.variance   = 50
        botWave.fps        = 80
        botWave.fillColor = #colorLiteral(red: 0.8705882353, green: 0.7294117647, blue: 0.6666666667, alpha: 1)
        botWave.backgroundColor = .clear
        botWave.waveWidth  = UIScreen.main.bounds.width * 1.5
        view.addSubview(botWave)
        
        view.bringSubviewToFront(indicatorView)
        view.bringSubviewToFront(collectionView)
        view.bringSubviewToFront(continueButton)
        
        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(restoreButton)
    }
    
    func updateIndicator() {
        secondIndicatorView.backgroundColor = continueButton.tag >= 1 ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        thirdIndicatorView.backgroundColor = continueButton.tag > 1 ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        if continueButton.tag == 2 {
            self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.showRestoreButton), userInfo: nil, repeats: false)
        }
    }
    
    @objc func showRestoreButton() {
        UIView.animate(withDuration: 0.3) {
            self.closeButton.alpha = 0.8
            self.restoreButton.alpha = 0.8
            self.view.layoutIfNeeded()
        }
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell) {
                continueButton.tag = indexPath.row
            }
        }
        
        updateIndicator()
    }
}

extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let onboardingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath as IndexPath) as! OnboardingCollectionViewCell
        onboardingCollectionViewCell.topImageView.image = UIImage.init(named: images[indexPath.row])
        
        let item = items[indexPath.row];
        for (key, value) in item {
            onboardingCollectionViewCell.titleLabel.text = key
            onboardingCollectionViewCell.descriptionLabel.text = value
        }
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1334:
                    print("iPhone 6/6S/7/8")
                    if indexPath.row != 2 {
                        onboardingCollectionViewCell.topImageView.contentMode = .scaleAspectFill
                    }
                default:
                    print("Unknown")
                }
            }
        
        if indexPath.row == 2 {
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                    case 1334:
                    print("iPhone 6/6S/7/8")
                        onboardingCollectionViewCell.topImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    case 2436:
                        print("iPhone X/XS/11 Pro")
                        onboardingCollectionViewCell.topImageView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                    case 2688:
                        print("iPhone XS Max/11 Pro Max")
                        onboardingCollectionViewCell.topImageView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                    case 1792:
                        print("iPhone XR/ 11 ")
                        onboardingCollectionViewCell.topImageView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                    default:
                        print("SMALL IPHONE")
                    }
                }
        } else {
            onboardingCollectionViewCell.topImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                    case 1334:
                        onboardingCollectionViewCell.topImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                default:
                    print("")
                }
            }
        }

        return onboardingCollectionViewCell
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
