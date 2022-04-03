//
//  EncodableExtensions.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/2/22.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        do {
            if let data = self as? Data {
                if data.isEmpty {
                    return nil
                }
                let result: [String: Any] = try JSONSerialization.jsonObject(with: data,
                                                                             options: []) as! [String : Any]
                return result
            } else {
                let result: [String: Any] = try JSONSerialization.jsonObject(with: JSONEncoder().encode(self),
                                                                             options: []) as! [String: Any]
                return result
            }
        } catch {
            assertionFailure("Check why it failed")
            return nil
        }
    }
}
