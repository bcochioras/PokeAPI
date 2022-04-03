//
//  PokeAPITests.swift
//  PokemonAppTests
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import XCTest
import PokemonApp
import Moya

final class RequestManagerIntegrationTests: XCTestCase {

    let requestManager = PokeRequestManager()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testListRequest() throws {
        let expectation = self.expectation(description: "Retrieving Pokemons")
        requestManager.getPokemons(limit: 10, offset: 0) { result in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDetailsRequest() throws {
        let expectation = self.expectation(description: "Retrieving Pokemon Details")
        requestManager.getPokemonDetails(id: 1) { result in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
