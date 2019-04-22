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

    /// Tests a task can be executed on a standard operation queue.
    ///
    /// Task requirements rely on coordination between the task and its associated task queue. This won't happen if the
    /// task is enqued on a standard `OperationQueue` which could leave the task in an indefinite pending state while it
    /// waits for requirements to be satisfied.
    //
    func testTaskCanExecuteOnStandardOperationQueue() {
        // Given
        let opQueue = OperationQueue()
        opQueue.isSuspended = true
        let exp = expectation(description: "The task's body is called")
        let task = BlockTask {
            exp.fulfill()
        }

        // When
        opQueue.addOperation(task)
        opQueue.isSuspended = false

        // Then
        waitForExpectations(timeout: 0.3)
    }

    /// Tests a task's standard operation dependencies work on a normal operation queue.
    func testTaskDependenciesWorkOnStandardOperationQueue() {
        // Given
        let opQueue = OperationQueue()
        opQueue.isSuspended = true

        let taskAExp = expectation(description: "Task A's body is called")
        let taskBExp = expectation(description: "Task B's body is called")

        let taskA = BlockTask {
            taskAExp.fulfill()
        }
        let taskB = BlockTask {
            taskBExp.fulfill()
        }

        taskB.addDependency(taskA)

        // When
        opQueue.addOperations([taskA, taskB], waitUntilFinished: false)
        opQueue.isSuspended = false

        // Then
        waitForExpectations(timeout: 0.3)
    }

}
