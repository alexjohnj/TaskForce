//
//  TaskQueueTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation
import XCTest
@testable import TaskForce

internal class TaskQueueTest: XCTestCase {
    // MARK: - Operation Queue Access
    /// Test `TaskQueue.main` behaves the same as `OperationQueue.current`.
    func testGetMainQueueMatchesOperationQueueBehaviour() {
        let mainTaskQueue = TaskQueue.main
        XCTAssertEqual(mainTaskQueue.operationQueue, OperationQueue.main)
    }

    /// Test `TaskQueue.current` behaves the same as `OperationQueue.current` when used outside a `Task`.
    func testGetCurrentQueueOutsideTaskMatchesOperationQueueBehaviour() {
        let operationQueue = OperationQueue.current
        let taskQueue = TaskQueue.current

        XCTAssertEqual(operationQueue, taskQueue?.operationQueue)
    }

    /// Test `TaskQueue.current` behaves the same as `OperationQueue.current` when used inside a `Task`.
    func testGetCurrentQueueInsideTaskMatchesOperationQueueBehaviour() {
        let blockExecutionExpectation = expectation(description: "Waiting for BlockTask's block to execute")
        let taskQueue = TaskQueue()
        let task = BlockTask {
            XCTAssertEqual(TaskQueue.current?.operationQueue, OperationQueue.current)
            blockExecutionExpectation.fulfill()
        }

        taskQueue.addTask(task)
        wait(for: [blockExecutionExpectation], timeout: 0.5)
    }

    // MARK: - Queue Management
    /// Test `TaskQueue.addTasks(tasks:) adds and executes all tasks
    func testAddMultipleTasksWorks() {
        var expectations = [XCTestExpectation]()
        var tasks = [BlockTask]()

        for _ in 1...5 {
            let exp = expectation(description: "")
            let task = BlockTask { exp.fulfill() }

            tasks.append(task)
            expectations.append(exp)
        }

        let taskQueue = TaskQueue()
        taskQueue.addTasks(tasks)
        wait(for: expectations, timeout: 0.5)
    }

    /// Test adding a block as a task works.
    func testAddBlockAsTaskWorks() {
        let blockExecutionExpectation = expectation(description: "Waiting for BlockTasks block to execute")
        let queue = TaskQueue()

        queue.addTask { blockExecutionExpectation.fulfill() }
        wait(for: [blockExecutionExpectation], timeout: 0.5)
    }

    /// Test TaskQueue.cancelAllTasks() cancels all tasks
    func testCancelAllTasksWorks() {
        let queue = TaskQueue()
        queue.isSuspended = true

        var tasks = [Task]()
        for _ in 1...5 { tasks.append(Task()) }
        queue.addTasks(tasks)

        queue.cancelAllTasks()

        for task in tasks {
            XCTAssertTrue(task.isCancelled)
        }
    }

    /// Test TaskQueue.cancelAllTasks() only cancels `Task` subclasses, not `Operation`s.
    func testCancellAllOnlyCancelsTasks() {
        let queue = TaskQueue()
        queue.isSuspended = true

        var tasks = [Task]()
        var operations = [Operation]()

        for _ in 1...5 {
            tasks.append(Task())
            operations.append(Operation())
        }

        queue.addTasks(tasks)
        queue.operationQueue.addOperations(operations, waitUntilFinished: false)

        queue.cancelAllTasks()

        for task in tasks {
            XCTAssertTrue(task.isCancelled)
        }

        for op in operations {
            XCTAssertFalse(op.isCancelled)
        }
    }

    // MARK: - Queue Properties

    /// Test accessing the `TaskQueue.tasks` property
    func testGetQueueTasks() {
        let queue = TaskQueue()
        queue.isSuspended = true
        let expectedTaskCount = 5

        for _ in 1...expectedTaskCount {
            queue.addTask { }
        }

        XCTAssertEqual(expectedTaskCount, queue.taskCount)
    }

    /// Test getting a queue's tasks filters `Operation` subclasses in a mixed queue.
    func testGetQueueTaskFiltersOperations() {
        let queue = TaskQueue()
        queue.isSuspended = true
        let expectedTaskCount = 5

        for _ in 1...expectedTaskCount {
            queue.addTask { }
            queue.operationQueue.addOperation { }
        }

        XCTAssertEqual(expectedTaskCount, queue.taskCount)
    }

    /// Test the value of the isSuspended property matches the OperationQueue.
    func testTaskQueueIsSuspendedReflectsOperationQueue() {
        let queue = TaskQueue()
        queue.isSuspended = false
        XCTAssertEqual(queue.operationQueue.isSuspended, false)

        queue.isSuspended = true
        XCTAssertEqual(queue.operationQueue.isSuspended, true)
    }

    // MARK: - Protocol Conformance

    /// Test TaskQueue equality matches OperationQueue equality
    func testTaskQueueEqualityMatchesOperationQueue() {
        let queueA = TaskQueue()
        let queueB = TaskQueue()
        let queueC = queueA

        XCTAssertNotEqual(queueA, queueB)
        XCTAssertEqual(queueA, queueC)
    }

    /// Test TaskQueue hash matches backing OperationQueue hash
    func testTaskQueueHashMatchesBackingOperationQueue() {
        let queue = TaskQueue()

        XCTAssertEqual(queue.hashValue, queue.operationQueue.hashValue)
    }
}
