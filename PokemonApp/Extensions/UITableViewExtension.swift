//
//  UITableViewExtension.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/3/22.
//

import Foundation
import UIKit

extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: cellType.className)
    }

    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type) -> T {
         return dequeueReusableCell(withIdentifier: type.className) as! T
    }
}
