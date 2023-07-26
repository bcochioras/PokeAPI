//
//  PokemonsResponse.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import Foundation

struct PokemonsResponse: Decodable {
    let count: Int?
    let next: URL?
    let previous: URL?
    let results: [Pokemon]?
    
    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
    
    struct Pokemon: Decodable {
        @Capitalized
        var name: String?
        let url: URL?
        
        var detailed: PokemonDetailed?
        
        enum CodingKeys: String, CodingKey {
            case name
            case url
        }


        init(from decoder:Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            url = try values.decode(URL.self, forKey: .url)
        }
    }
}

extension PokemonsResponse.Pokemon: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(name)
    }
}

extension PokemonsResponse.Pokemon: Equatable {
    static func ==(lhs: PokemonsResponse.Pokemon, rhs: PokemonsResponse.Pokemon) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
