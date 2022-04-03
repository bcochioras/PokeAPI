//
//  PokeDetailsVM.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/2/22.
//

import Foundation
import RxSwift
import RxCocoa

final class PokeDetailsVM {
    
    private let requestManager = PokeRequestManager()
    let disposeBag = DisposeBag()
    
    private let pokemon: BehaviorRelay<PokemonsResponse.Pokemon>
    var pokemonObservable: Driver<PokemonsResponse.Pokemon> {
        return pokemon.asDriver()
    }
    
    private let isLoading = BehaviorRelay<Bool>(value: false)
    var isLoadingObservable: Driver<Bool> {
        return isLoading.asDriver()
    }
    
    private let serverError = BehaviorRelay<Error?>(value: nil)
    var serverErrorObservable: Driver<Error?> {
        return serverError.asDriver()
    }
    
    init(pokemon: PokemonsResponse.Pokemon) {
        self.pokemon = BehaviorRelay<PokemonsResponse.Pokemon>(value: pokemon)
    }
    
    func loadDetails() {
        guard !isLoading.value,
              let url = pokemon.value.url else {
            return
        }
        isLoading.accept(true)
        requestManager.getPokemonsFrom(url: url) { [weak self] response in
            guard let self = self else {
                return
            }
            switch response {
            case .failure(let error):
                self.serverError.accept(error)
            case .success(let details):
                var temp = self.pokemon.value
                temp.detailed = details
                self.pokemon.accept(temp)
            }
            self.isLoading.accept(false)
        }
    }
}
