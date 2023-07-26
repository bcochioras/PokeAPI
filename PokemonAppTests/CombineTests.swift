//
//  CombineTests.swift
//  PokemonAppTests
//
//  Created by Cochioras Bogdan-Ionut on 25.07.2023.
//

import Foundation
import Combine
import XCTest


final class CombineTests : XCTestCase {
    private var cancellables: Set<AnyCancellable>!


    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }


    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }


    // MARK: - PassthroughSubject

    func test_publisherSinkIsCalled() {
        let publisher = PassthroughSubject<Int, Never>()
        let expectedValue = Int.random(in: 0...100)

        let notCalledExpectation = expectation(description: "Expected to not be called because it is not stored")
        notCalledExpectation.isInverted = true
        _ = publisher.sink { value in
            notCalledExpectation.fulfill()
        }
        publisher.send(expectedValue)
        waitForExpectations(timeout: 0.3)


        let isCalledExpectation = expectation(description: "Expected to not be called because it is not stored")
        publisher.sink { value in
            XCTAssertEqual(expectedValue, value)
            isCalledExpectation.fulfill()
        }.store(in: &cancellables)
        publisher.send(expectedValue)
        waitForExpectations(timeout: 1)
    }


    func test_publisherRegistration() {
        let publisher = PassthroughSubject<Int, Never>()
        let expectation = expectation(description: "Should call sink")

        // will not call sink because it is not registered yet
        publisher.send(1)

        publisher.sink { value in
            XCTAssertEqual(value, 2)
            expectation.fulfill()
        }.store(in: &cancellables)

        // will call sink because it is registered above
        publisher.send(2)

        waitForExpectations(timeout: 1)
    }


    func test_multipleSubscriptions() {
        let publisher = PassthroughSubject<Int, Never>()
        let expectation = expectation(description: "Should call sink")
        expectation.expectedFulfillmentCount = 2

        publisher.sink { value in
            XCTAssertEqual(value, 2)
            expectation.fulfill()
        }.store(in: &cancellables)

        publisher.sink { value in
            XCTAssertEqual(value, 2)
            expectation.fulfill()
        }.store(in: &cancellables)

        // will call sink because it is registered above
        publisher.send(2)

        waitForExpectations(timeout: 1)
    }


    func test_publisherReceiveOn() {
        let publisher = PassthroughSubject<Int, Never>()
        let backgroundQueue = DispatchQueue(label: "background queue", qos: .background)
        let utilityQueue = DispatchQueue(label: "utility queue", qos: .utility)

        let expectation1 = expectation(description: "Should call sink on background queue")
        publisher
            .first()
            .sink { value in
                XCTAssertEqual(String(cString: __dispatch_queue_get_label(nil), encoding: .utf8), backgroundQueue.label)
                XCTAssertEqual(value, 1)
                expectation1.fulfill()
            }.store(in: &cancellables)
        backgroundQueue.async {
            publisher.send(1)
        }
        waitForExpectations(timeout: 1)

        let expectation2 = expectation(description: "Should call sink on utility queue")
        publisher
            .first()
            .receive(on: utilityQueue)
            .sink { value in
                XCTAssertEqual(String(cString: __dispatch_queue_get_label(nil), encoding: .utf8), utilityQueue.label)
                XCTAssertEqual(value, 2)
                expectation2.fulfill()
        }.store(in: &cancellables)
        backgroundQueue.async {
            publisher.send(2)
        }
        waitForExpectations(timeout: 1)


        let currentQueue = OperationQueue.current!.underlyingQueue
        let expectation3 = expectation(description: "Should call sink on current queue")
        publisher
            .sink { value in
                XCTAssertEqual(currentQueue, OperationQueue.current!.underlyingQueue)
                XCTAssertEqual(value, 3)
                expectation3.fulfill()
        }.store(in: &cancellables)
        publisher.send(3)
        waitForExpectations(timeout: 1)
    }


    func test_notificationsAreReceived() {
        let name = NSNotification.Name("testNotification")
        let expectation = expectation(description: "Should have triggered notification")

        NotificationCenter.Publisher(center: .default, name: name)
            .sink { notification in
                print(notification)
                expectation.fulfill()
            }.store(in: &cancellables)

        NotificationCenter.default.post(Notification(name: name))

        waitForExpectations(timeout: 1)
    }


    func test_collectByTime() {
        let timeToWaitForCollecting = 0.2
        let expectation = expectation(description: "Expected to call sink once")
        expectation.expectedFulfillmentCount = 3
        let publisher = PassthroughSubject<Int, Never>()
        let startDate = Date()

        publisher
            .collect(.byTime(DispatchQueue.main, .seconds(timeToWaitForCollecting)))
            .sink { value in
                let elapsedTime = Date().timeIntervalSince(startDate)
                print("test_collect: value count is \(value.count), elapsedTime: \(elapsedTime)")
                XCTAssertTrue(elapsedTime > timeToWaitForCollecting)
                expectation.fulfill()
            }.store(in: &cancellables)

        (1...100).forEach { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.1...0.7)) {
                publisher.send(Int.random(in: 0...100))
            }
        }
        waitForExpectations(timeout: 1)
    }


    func test_collectByTimeOrCount() {
        let maximumElementsCount = 10
        let expectation = expectation(description: "Expected to call sink once")
        expectation.expectedFulfillmentCount = 4
        let publisher = PassthroughSubject<Int, Never>()
        let startDate = Date()

        publisher
            .collect(.byTimeOrCount(DispatchQueue.main, 0.9, maximumElementsCount))
            .sink { values in
                let elapsedTime = Date().timeIntervalSince(startDate)
                print("test_collectByTimeOrCount: values count is \(values.count), elapsedTime: \(elapsedTime)")
                XCTAssertTrue(values.count <= maximumElementsCount)
                expectation.fulfill()
            }.store(in: &cancellables)

        (1...39).forEach { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.1...0.7)) {
                publisher.send(Int.random(in: 0...100))
            }
        }
        waitForExpectations(timeout: 1)
    }


    func test_chaining() {
        let publisher = PassthroughSubject<[Int], Never>()
        let expectation = expectation(description: "Expected to call sink")
        publisher
            .flatMap { Publishers.Sequence(sequence: $0) } // split array to separate elements
            .filter({ $0.isMultiple(of: 2)}) // 0, 2, 4
            .reduce(0, +) // 0 + 2 + 4
            .map({ String($0) }) // 6
            .sink { value in
                XCTAssertEqual(value, "6")
                expectation.fulfill()
            }.store(in: &cancellables)

        publisher.send(Array(0...5))
        publisher.send(completion: .finished)
        waitForExpectations(timeout: 1)
    }

    // MARK: - CurrentValueSubject

    func test_currentValueSubjectSink() {
        let expectation = expectation(description: "Expected to call sink")
        expectation.expectedFulfillmentCount = 2
        let subject = CurrentValueSubject<Int, Never>(5)

        subject.send(3)

        subject.sink { value in
            XCTAssertEqual(value, 3)
            expectation.fulfill()
        }.store(in: &cancellables)

        subject.sink { value in
            XCTAssertEqual(value, 3)
            expectation.fulfill()
        }.store(in: &cancellables)

        waitForExpectations(timeout: 1)
    }


    func test_currentValueSubjectDropFirst() {
        let itemsToDrop = 2
        let expectation = expectation(description: "Expected to call sink")
        let subject = CurrentValueSubject<Int, Never>(5)

        XCTAssertEqual(subject.value, 5)

        subject.dropFirst(itemsToDrop)
            .sink { value in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
            }.store(in: &cancellables)

        subject.send(2)
        XCTAssertEqual(subject.value, 2)

        subject.send(3)
        XCTAssertEqual(subject.value, 3)

        waitForExpectations(timeout: 1)
    }


    func test_currentValueSubjectIsNotThreadSafe() {
        let subject = CurrentValueSubject<Int, Never>(0)
        let backgroundQueue = DispatchQueue(label: "background queue", qos: .background)
        let expectation = expectation(description: "Expected to call sink")
        expectation.assertForOverFulfill = false
        for expectedValue in (1...10) {
            subject
                .dropFirst()
                .receive(on: backgroundQueue) // if commented test will pass because work is on the curent thread
                .first()
                .sink { receivedValue in
                    XCTAssertEqual(subject.value, expectedValue)
                    XCTAssertEqual(receivedValue, expectedValue)
                    expectation.fulfill()
                }.store(in: &cancellables)
            subject.send(expectedValue)
        }

        waitForExpectations(timeout: 1)
    }
}
