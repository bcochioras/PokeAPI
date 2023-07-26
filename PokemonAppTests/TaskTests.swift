//
//  TaskTests.swift
//  PokemonAppTests
//
//  Created by Cochioras Bogdan-Ionut on 25.07.2023.
//

import Foundation
import Combine
import XCTest


final class TaskTests : XCTestCase {

    func test_taskCurrentQueue() {
        let currentQueue = String(cString: __dispatch_queue_get_label(nil))
        Task {
            XCTAssertEqual(currentQueue, String(cString: __dispatch_queue_get_label(nil)))
        }
    }


    func test_taskDetachedNotOnCurrentQueue() {
        let currentQueue = String(cString: __dispatch_queue_get_label(nil))
        let expectation = expectation(description: "expected to call task")
        // priority can be ommited
        Task.detached(priority: .low) {
            XCTAssertNotEqual(currentQueue, String(cString: __dispatch_queue_get_label(nil)))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }


    func test_taskCancelationMethod1() {
        let expectation = expectation(description: "expected to be reached")
        let task = Task.detached(priority: .background) {
            do {
                try Task.checkCancellation()
            } catch {
                expectation.fulfill()
            }
        }
        task.cancel()
        
        XCTAssertTrue(task.isCancelled)
        waitForExpectations(timeout: 1)
    }


    func test_taskCancelationMethod2() {
        let expectation = expectation(description: "expected not to be reached")
        expectation.isInverted = true
        let task = Task.detached(priority: .background) {
            try Task.checkCancellation()
            expectation.fulfill()
        }
        task.cancel()
        
        XCTAssertTrue(task.isCancelled)
        waitForExpectations(timeout: 1)
    }


    func test_taskValue() async {
        let task = Task {
            return 3
        }
        let taskValue = await task.value
        XCTAssertEqual(taskValue, 3)
    }


    func test_asyncLet() async {
        let task1 = Task.detached(priority: .low) {
            return 1
        }
        let task2 = Task.detached(priority: .high) {
            return 2
        }
        async let sum1 = task1.value + task2.value

        let task3 = Task.detached(priority: .background) {
            return 3
        }
        let task4 = Task.detached(priority: .utility) {
            return 4
        }
        async let sum2 = task3.value + task4.value

        let total = await sum1 + sum2
        // the below line is not supported in swift, maybe in a future version :(
//        async let total = sum1 + sum2
        XCTAssertEqual(total, 10)
    }


    func test_taskGroups() async throws {
        @Sendable func makeTask() -> Task<Int, Error> {
            Task.detached {
                return 3
            }
        }
        let total = try await withThrowingTaskGroup(of: Int.self) { taskGroup in
            (1...3).forEach { _ in
                taskGroup.addTask {
                    return try await makeTask().value
                }
            }
            var sum = 0
            while let newValue = try await taskGroup.next() {
                sum += newValue
            }
            return sum
        }
        XCTAssertEqual(total, 9)
    }
}
