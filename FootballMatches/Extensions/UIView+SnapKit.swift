//
//  UIView+SnapKit.swift
//  FootballMatches
//
//  Created by Hai Pham on 03/03/2023.
//

import SnapKit
import UIKit

extension UIView {
    var safeArea: ConstraintBasicAttributesDSL {
        return self.safeAreaLayoutGuide.snp
    }
    
}
