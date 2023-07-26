//
//  PokeAPI.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import Foundation
import Moya


/// Pokemon API requests definitions.
public enum PokeAPI {
    /// Pokemon data.
    case getPokemons(limit: Int, offset: Int)
    case getPokemonsFrom(url: URL)
}

/// Pokemon API requests target.
extension PokeAPI: TargetType {
    public var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    public var baseURL: URL {
        switch self {
        case .getPokemons(_,_):
            return URL(string: "https://pokeapi.co/api/v2")!
        case .getPokemonsFrom(let url):
            return url
        }
    }
    
    public var path: String {
        switch self {
        case .getPokemons(_,_):
            return "/pokemon"
        case .getPokemonsFrom(_):
            return ""
        }
    }
    
    public var task: Task {
        switch self {
        case .getPokemons(let limit, let offset):
            var parameters: [String: Int] = [:]
            if limit > -1 {
                parameters["limit"] = limit
            }
            if offset > -1 {
                parameters["offset"] = offset
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getPokemonsFrom(_):
            return .requestPlain
        }
    }
    
    public var validationType: ValidationType {
        switch self {
        case .getPokemons(_,_): fallthrough
        case .getPokemonsFrom(_):
            return .successCodes
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var method: Moya.Method {
        switch self {
        case .getPokemons(_,_): fallthrough
        case .getPokemonsFrom(_):
            return .get
        }
    }
}
