//
//  OfferCollectionViewCell.swift
//  Vibrarelax
//
//  Created by Artur Mukhutdinov on 22.05.2021.
//

import UIKit
import GRView

class OfferCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var topLabelView: GRView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bottomView: GRView!
    @IBOutlet weak var containerView: GRView!
}
