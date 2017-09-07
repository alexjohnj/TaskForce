//
//  CoreTaskTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation
import XCTest
@testable import TaskForce

// swiftlint:disable identifier_name
internal class CoreTaskTests: XCTestCase {
    class SimpleMockTask: Task {
        let x: Double
        let y: Double
        var result: Double?

        init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }

        override func execute() {
            if isCancelled {
                finish()
                return
            } else {
                result = x + y
                finish()
            }
        }
    }

    /// Test a task can successfully execute.
    func testExecutingTaskWorks() {
        let opQueue = OperationQueue()
        let expectedResult = 10.0
        let testExpectation = expectation(description: "Waiting for task to complete")

        let task = SimpleMockTask(x: 5.0, y: 5.0)
        task.completionBlock = {
            testExpectation.fulfill()
        }

        opQueue.addOperation(task)
        wait(for: [testExpectation], timeout: 0.5)

        XCTAssertEqual(task.result, expectedResult)
    }

    /// Tests cancelling a task before it is started results in it being finished immediately.
    func testCancellingTaskBeforeStartWorks() {
        let opQueue = OperationQueue()
        let testExpectation = expectation(description: "Waiting for task to complete")

        let task = SimpleMockTask(x: 5.0, y: 5.0)
        task.completionBlock = {
            testExpectation.fulfill()
        }

        task.cancel()
        opQueue.addOperation(task)
        wait(for: [testExpectation], timeout: 0.5)
        XCTAssertNil(task.result)
    }

    /// Tests that taskB starts after taskA finisheds when taskB depends on taskA
    func testTaskDependenciesWorks() {
        let opQueue = OperationQueue()
        let taskAExpect = expectation(description: "Waiting for task A to complete")
        let taskBExpect = expectation(description: "Waiting for task B to complete")
        let expectedResult = 10.0

        let taskA = SimpleMockTask(x: 5.0, y: 5.0)
        let taskB = SimpleMockTask(x: 5.0, y: 5.0)
        taskB.addDependency(taskA)

        taskA.completionBlock = { taskAExpect.fulfill() }
        taskB.completionBlock = { taskBExpect.fulfill() }

        opQueue.isSuspended = true
        opQueue.addOperation(taskA)
        opQueue.addOperation(taskB)
        opQueue.isSuspended = false

        wait(for: [taskAExpect, taskBExpect], timeout: 0.5)

        XCTAssertEqual(taskA.result, expectedResult)
        XCTAssertEqual(taskB.result, expectedResult)
    }

}
