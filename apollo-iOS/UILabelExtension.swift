//
//  UILabelExtension.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2019-03-15.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

extension UILabel {
    func setupLabel(fontWeight: UIFont.Weight, fontSize: CGFloat, textColor: UIColor = UIColor.white) {
        font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        self.textColor = textColor
        adjustsFontSizeToFitWidth = true
        baselineAdjustment = .alignCenters
    }
}
