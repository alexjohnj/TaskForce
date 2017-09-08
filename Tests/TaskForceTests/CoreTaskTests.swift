//
//  CoreTaskTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation
import XCTest
@testable import TaskForce

internal class CoreTaskTests: XCTestCase {
    /// Test a task can successfully execute.
    func testExecutingTaskWorks() {
        let opQueue = TaskQueue()
        let expectedResult = 10.0
        let testExpectation = expectation(description: "Waiting for task to complete")

        let task = MockAdditionTask(x: 5.0, y: 5.0)
        task.completionBlock = {
            testExpectation.fulfill()
        }

        opQueue.addTask(task)
        wait(for: [testExpectation], timeout: 0.5)

        XCTAssertEqual(task.result, expectedResult)
    }

    /// Tests cancelling a task before it is started results in it being finished immediately.
    func testCancellingTaskBeforeStartWorks() {
        let opQueue = TaskQueue()
        let testExpectation = expectation(description: "Waiting for task to complete")

        let task = MockAdditionTask(x: 5.0, y: 5.0)
        task.completionBlock = {
            testExpectation.fulfill()
        }

        task.cancel()
        opQueue.addTask(task)
        wait(for: [testExpectation], timeout: 0.5)
        XCTAssertNil(task.result)
    }

    /// Tests that taskB starts after taskA finisheds when taskB depends on taskA
    func testTaskDependenciesWorks() {
        let opQueue = TaskQueue()
        let taskAExpect = expectation(description: "Waiting for task A to complete")
        let taskBExpect = expectation(description: "Waiting for task B to complete")
        let expectedResult = 10.0

        let taskA = MockAdditionTask(x: 5.0, y: 5.0)
        let taskB = MockAdditionTask(x: 5.0, y: 5.0)
        taskB.addDependency(taskA)

        taskA.completionBlock = { taskAExpect.fulfill() }
        taskB.completionBlock = { taskBExpect.fulfill() }

        opQueue.isSuspended = true
        opQueue.addTask(taskA)
        opQueue.addTask(taskB)
        opQueue.isSuspended = false

        wait(for: [taskAExpect, taskBExpect], timeout: 0.5)

        XCTAssertEqual(taskA.result, expectedResult)
        XCTAssertEqual(taskB.result, expectedResult)
    }

}
