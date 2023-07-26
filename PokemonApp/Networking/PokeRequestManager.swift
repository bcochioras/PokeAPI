//
//  RequestManager.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import Foundation
import Moya
import Combine


final class PokeRequestManager {
    private static let decoder: JSONDecoder = {
        let temp = JSONDecoder()
        temp.keyDecodingStrategy = .convertFromSnakeCase
        return temp
    }()
    
    private let provider = MoyaProvider<PokeAPI>(plugins: [
//        NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .formatRequestAscURL)),
//        NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .errorResponseBody))
    ])
    

    func getPokemons(limit: Int, offset: Int)  async throws -> PokemonsResponse {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.provider.request(PokeAPI.getPokemons(limit: limit, offset: offset)) { result in
                switch result {
                case .success(let response):
                    do {
                        let response = try response.map(PokemonsResponse.self)
                        continuation.resume(returning: response)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }


    func getPokemonsFrom(url: URL) async throws -> PokemonDetailed {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.provider.request(PokeAPI.getPokemonsFrom(url: url)) { result in
                switch result {
                case .success(let response):
                    do {
                        let response = try response.map(PokemonDetailed.self, using: Self.decoder)
                        continuation.resume(returning: response)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
