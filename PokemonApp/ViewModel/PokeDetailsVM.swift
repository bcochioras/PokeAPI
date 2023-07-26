//
//  PokeDetailsVM.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/2/22.
//

import Foundation
import Combine

final class PokeDetailsVM {
    
    private let requestManager = PokeRequestManager()
    private var fetchDetailsTask: Task<Void, Error>?
    
    private let pokemon: CurrentValueSubject<PokemonsResponse.Pokemon, Never>
    var pokemonObservable: AnyPublisher<PokemonsResponse.Pokemon, Never> {
        pokemon.eraseToAnyPublisher()
    }
    
    private let isLoading = CurrentValueSubject<Bool, Never>(false)
    var isLoadingObservable: AnyPublisher<Bool, Never> {
        isLoading.eraseToAnyPublisher()
    }
    
    private let serverError = CurrentValueSubject<Error?, Never>(nil)
    var serverErrorObservable: AnyPublisher<Error?, Never> {
        serverError.eraseToAnyPublisher()
    }
    
    init(pokemon: PokemonsResponse.Pokemon) {
        self.pokemon = CurrentValueSubject<PokemonsResponse.Pokemon, Never>(pokemon)
    }
    
    func loadDetails() {
        guard !isLoading.value,
              let url = pokemon.value.url else {
            return
        }
        isLoading.send(true)
        fetchDetailsTask = Task.detached(priority: .background) { [weak self] in
            guard let self else {
                return
            }
            do {
                let details = try await self.requestManager.getPokemonsFrom(url: url)
                var temp = self.pokemon.value
                temp.detailed = details
                self.pokemon.send(temp)
            } catch {
                self.serverError.send(error)
            }
            self.isLoading.send(false)
        }
    }


    deinit {
        fetchDetailsTask?.cancel()
    }
}
