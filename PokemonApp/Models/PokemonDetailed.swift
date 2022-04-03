//
//  PokemonDetailed.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/2/22.
//

import Foundation
import Moya
import AnyCodable

struct PokemonDetailed: Codable {
    let id: Int
    let name: String?
    let sprites: Sprites?
    let height: Int?
    let weight: Int?
    let baseExperience: Int?
    
    let extraInfo: [String: AnyCodable]?
    
    struct Sprites: Codable {
        let frontDefault: URL?
        let frontShiny: URL?
        let frontFemale: URL?
        let frontShinyFemale: URL?
        let backDefault: URL?
        let backShiny: URL?
        let backFemale: URL?
        let backShinyFemale: URL?
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sprites
        case height
        case weight
        case baseExperience
    }
    
    func encode(to encoder: Encoder) throws {
        try extraInfo?.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(sprites, forKey: .sprites)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(baseExperience, forKey: .baseExperience)
    }
    
    init(from decoder: Decoder) throws {
        extraInfo = try [String: AnyCodable](from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        sprites = try container.decodeIfPresent(Sprites.self, forKey: .sprites)
        height = try container.decodeIfPresent(Int.self, forKey: .height)
        weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        baseExperience = try container.decodeIfPresent(Int.self, forKey: .baseExperience)
    }
}
