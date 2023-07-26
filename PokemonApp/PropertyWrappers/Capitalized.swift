//
//  Capitalized.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan-Ionut on 26.07.2023.
//


@propertyWrapper
struct Capitalized {
    var wrappedValue: String? {
        didSet {
            wrappedValue = wrappedValue?.capitalized
        }
    }

    init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue?.capitalized
    }
}
