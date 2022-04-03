//
//  UIstackViewExtension.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/3/22.
//

import Foundation
import UIKit

extension UIStackView {
    
    convenience init(axis: NSLayoutConstraint.Axis) {
        self.init()
        self.axis = axis
    }
}
