//
//  PokeVM.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import Kingfisher
import OrderedCollections

final class PokeFeedVM {
    
    private let limit: Int = 10
    private var offset: Int = 0
    
    private let requestManager = PokeRequestManager()
    private var lastResponse: PokemonsResponse?
    
    private let isLoading = BehaviorRelay<Bool>(value: false)
    var isLoadingObservable: Driver<Bool> {
        return isLoading.asDriver()
    }
    
    private let serverError = BehaviorRelay<Error?>(value: nil)
    var serverErrorObservable: Driver<Error?> {
        return serverError.asDriver()
    }
    
    private let listData = BehaviorRelay<OrderedSet<PokemonsResponse.Pokemon>>(value: [])
    var listDataObservable: Observable<OrderedSet<PokemonsResponse.Pokemon>> {
        return listData.asObservable()
    }
    
    var canLoadMore: Bool {
        // first request
        return lastResponse == nil ||
        // has more data to load
        lastResponse?.next != nil
    }
    
    func loadMore(isRefresh: Bool) {
        guard !isLoading.value,
        canLoadMore else {
            // still loading data
            return
        }
        isLoading.accept(true)
        
        let newOffset: Int
        if lastResponse != nil,
           !isRefresh {
            // fetch next page
            newOffset = offset + limit
        } else {
            // refresh data
            newOffset = 0
        }
        
        requestManager.getPokemons(limit: limit, offset: newOffset) { [weak self] response in
            guard let self = self else {
                return
            }
            switch response {
            case .failure(let error):
                self.serverError.accept(error)
            case .success(let response):
                if newOffset == 0 {
                    self.listData.accept(OrderedSet(response.results ?? []))
                    self.lastResponse = response
                } else {
                    self.listData.accept(self.listData.value.union(response.results ?? []))
                }
                self.offset = newOffset
            }
            self.isLoading.accept(false)
        }
    }
    
    func data(at indexPath: IndexPath) -> PokemonsResponse.Pokemon? {
        return listData.value[safe: indexPath.row]
    }
}
