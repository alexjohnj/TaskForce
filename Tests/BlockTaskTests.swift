//
//  BlockTaskTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation
import XCTest
@testable import TaskForce

internal class BlockTaskTests: XCTestCase {
    /// Test a block task executes its attached block
    func testBlockTaskExecutes() {
        let resultExpectation = expectation(description: "Waiting for BlockTask's block to execute")
        let opQueue = TaskQueue()

        let task = BlockTask { resultExpectation.fulfill() }

        opQueue.addTask(task)
        wait(for: [resultExpectation], timeout: 0.5)
    }

    /// Test a block task updates its finished state when done.
    func testBlockTaskUpdatesFinishState() {
        let completionExpectation = expectation(description: "Waiting for BlockTask's completion block to execute")
        let opQueue = TaskQueue()
        let task = BlockTask { }
        task.completionBlock = { completionExpectation.fulfill() }

        opQueue.addTask(task)
        wait(for: [completionExpectation], timeout: 0.5)

        XCTAssertTrue(task.isFinished)
    }

    func testBlockTaskClosureIsPassedTheTaskInstance() {
        // Given
        let exp = expectation(description: "Task's body should be executed.")
        let queue = TaskQueue()
        var task: BlockTask!
        task = BlockTask { passedTask in
            XCTAssert(task === passedTask)
            exp.fulfill()
        }

        // When
        queue.addTask(task)

        // Then
        wait(for: [exp], timeout: 0.1)
    }
}
