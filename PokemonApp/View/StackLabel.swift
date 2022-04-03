//
//  StackLabel.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/3/22.
//

import Foundation
import UIKit

final class StackLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setContentCompressionResistancePriority(.required,
                                                for: .vertical)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
