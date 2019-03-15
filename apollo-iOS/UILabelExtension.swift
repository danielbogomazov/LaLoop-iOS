//
//  UILabelExtension.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2019-03-15.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

extension UILabel {
    func setupLabel(fontWeight: UIFont.Weight, textColor: UIColor = UIColor.white) {
        font = UIFont.monospacedDigitSystemFont(ofSize: bounds.height, weight: fontWeight)
        self.textColor = textColor
        baselineAdjustment = .alignCenters
        adjustsFontSizeToFitWidth = true
    }
}
