//
//  PokeVM.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import Foundation
import Combine
import Kingfisher
import OrderedCollections


final class PokeFeedVM {

    typealias Pokemon = PokemonsResponse.Pokemon

    private var cancellables = Set<AnyCancellable>()
    private let limit: Int = 10
    private var offset: Int = 0
    
    private let requestManager = PokeRequestManager()
    private var lastResponse: PokemonsResponse?
    private var fetchTask: Task<Void, Error>?
    
    private let isLoading = CurrentValueSubject<Bool, Never>(false)
    var isLoadingObservable: AnyPublisher<Bool, Never> {
        return isLoading.eraseToAnyPublisher()
    }
    
    private let serverError = CurrentValueSubject<Error?, Never>(nil)
    var serverErrorObservable: AnyPublisher<Error?, Never> {
        return serverError.eraseToAnyPublisher()
    }
    
    private let listData = CurrentValueSubject<OrderedSet<Pokemon>, Never>([])
    var listDataObservable: AnyPublisher<OrderedSet<Pokemon>, Never> {
        return listData.eraseToAnyPublisher()
    }

    private let pokemonViewedCollector = PassthroughSubject<Pokemon, Never>()


    init() {
        setupObservers()
    }


    var canLoadMore: Bool {
        // first request
        return lastResponse == nil ||
        // has more data to load
        lastResponse?.next != nil
    }

    var numberOfRow: Int {
        listData.value.count
    }


    func loadMoreIfNeeded(for indexPath: IndexPath) {
        guard indexPath.row >= numberOfRow - 4 else {
            return
        }
        loadMore(isRefresh: false)
    }


    func loadMore(isRefresh: Bool) {
        guard !isLoading.value, canLoadMore else {
            // still loading data
            return
        }
        isLoading.send(true)
        
        let newOffset: Int
        if lastResponse != nil,
           !isRefresh {
            // fetch next page
            newOffset = offset + limit
        } else {
            // refresh data
            newOffset = 0
        }

        fetchTask = Task.detached(priority: .background) { [weak self] in
            guard let self else {
                return
            }
            do {
                let response = try await self.requestManager.getPokemons(limit: self.limit, offset: newOffset)
                if newOffset == 0 {
                    self.listData.send(OrderedSet(response.results ?? []))
                    self.lastResponse = response
                } else {
                    self.listData.send(self.listData.value.union(response.results ?? []))
                }
                self.offset = newOffset
            } catch {
                self.serverError.send(error)
            }
            self.isLoading.send(false)
        }
    }


    func data(at indexPath: IndexPath) -> Pokemon? {
        listData.value[safe: indexPath.row]
    }


    func logPokemonViewed(_ pokemon: Pokemon) {
        pokemonViewedCollector.send(pokemon)
    }

    private func setupObservers() {
        pokemonViewedCollector
            .collect(.byTime(DispatchQueue(label: "aQueue", qos: .utility), .seconds(1)))
            .sink { pokemons in
                pokemons.forEach { pokemon in
                    print("Did view pokemon: \(pokemon.name ?? "")")
                }
            }.store(in: &cancellables)
    }


    deinit {
        fetchTask?.cancel()
    }
}
