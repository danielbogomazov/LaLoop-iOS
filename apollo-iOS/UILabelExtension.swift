//
//  UILabelExtension.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2019-03-15.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

extension UILabel {
    
    /// Abstracted for convenience and consistency.
    ///
    /// - Parameters:
    ///   - fontWeight: Weight of the font.
    ///   - fontSize: Size of the font. NOTE : Size is reduced if the text does not fit in the bounds.
    ///   - textColor: Color of the font.
    func setupLabel(fontWeight: UIFont.Weight, fontSize: CGFloat, textColor: UIColor = UIColor.white) {
        font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        self.textColor = textColor
        adjustsFontSizeToFitWidth = true
        baselineAdjustment = .alignCenters
        numberOfLines = 0
        lineBreakMode = .byTruncatingTail
    }
}
