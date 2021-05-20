//
//  OnboardingViewController.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 20.05.2021.
//

import UIKit
import WaveAnimationView
import GRView

class OnboardingViewController: UIViewController {
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: GRButton!
    @IBOutlet weak var secondIndicatorView: UIView!
    @IBOutlet weak var thirdIndicatorView: UIView!
    
    var waveAnimationView: WaveAnimationView!
    var waveBottomAnimationView: WaveAnimationView!
    
    let items: [[String : String]] = [["Добро пожаловать в Vibrarelax" : "Массаж расслабляет. 60 минут хорошего массажа оказывают такое же воздействие на ваш организм, как 7-8 часов хорошего сна."], ["Наслаждайтесь сильной вибрацией" : "Знаетели Вы, что на нашей коже приблизительно 5 миллионов рецепторов, причем только 3000 на одном кончике языка"], ["Попробуй со всеми режимами PRO" : "9 режимов вибраций, 5 режимов скорости, никакой рекламы, еженедельное обновление контента за 459 ₽ / еженедельно."]]
    let images: [String] = ["ic_onboarding_first", "ic_onboarding_second", "ic_onboarding_third"]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setupWaveAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        waveAnimationView.stopAnimation()
        waveBottomAnimationView.stopAnimation()
    }
    
    // MARK: -
    // MARK: - ACTIONS
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        if (sender.tag == 2) {
            UserDefaults.standard.setValue(true, forKey: "onboarding")
            navigationController?.pushViewController(BottomNavigationViewController(), animated: true)
        } else {
            collectionView.scrollToItem(at: IndexPath(item: sender.tag + 1, section: 0), at: .centeredHorizontally, animated: true)
            sender.tag += 1
        }
        
        updateIndicator()
    }
    
    
    // MARK: -
    // MARK: - FUNCTIONS
    
    func setupWaveAnimations() {
        waveAnimationView = WaveAnimationView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5), color: #colorLiteral(red: 0.9294117647, green: 0.2666666667, blue: 0.3647058824, alpha: 1))
        view.addSubview(waveAnimationView)
        waveAnimationView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        waveAnimationView.startAnimation()
        
        waveBottomAnimationView = WaveAnimationView(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.height - (UIScreen.main.bounds.height / 4), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 4), color: #colorLiteral(red: 0.8705882353, green: 0.7294117647, blue: 0.6666666667, alpha: 1))
        view.addSubview(waveBottomAnimationView)
        waveBottomAnimationView.startAnimation()
        
        view.bringSubviewToFront(indicatorView)
        view.bringSubviewToFront(collectionView)
        view.bringSubviewToFront(continueButton)
    }
    
    func updateIndicator() {
        secondIndicatorView.backgroundColor = continueButton.tag >= 1 ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
        thirdIndicatorView.backgroundColor = continueButton.tag > 1 ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
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

        return onboardingCollectionViewCell
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
