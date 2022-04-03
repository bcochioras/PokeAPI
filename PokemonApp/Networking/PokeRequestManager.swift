//
//  RequestManager.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import Foundation
import Moya

struct PokeRequestManager {
    
    enum Response<SuccessResponse, FailureResponse> {
        case success(SuccessResponse)
        case failure(FailureResponse)
    }
    
    private let provider = MoyaProvider<PokeAPI>(plugins: [
        NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
    ])
    
    @discardableResult
    func getPokemons(limit: Int, offset: Int, completion: @escaping (Response<PokemonsResponse, Error>) -> Void) -> Cancellable {
        provider.request(PokeAPI.getPokemons(limit: limit, offset: offset), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let response = try response.map(PokemonsResponse.self)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    @discardableResult
    func getPokemonDetails(id: Int, completion: @escaping (Response<PokemonDetailed, Error>) -> Void) -> Cancellable {
        provider.request(PokeAPI.getPokemonDetails(id: id), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try response.map(PokemonDetailed.self, using: decoder)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    @discardableResult
    func getPokemonsFrom(url: URL, completion: @escaping (Response<PokemonDetailed, Error>) -> Void) -> Cancellable {
        provider.request(PokeAPI.getPokemonsFrom(url: url), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try response.map(PokemonDetailed.self, using: decoder)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
