//
//  ArrayExtension.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/2/22.
//

import Foundation
import OrderedCollections

extension Array {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension OrderedSet {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
