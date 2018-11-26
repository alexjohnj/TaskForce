//
//  TaskGroupTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 11/09/2017.
//

import Foundation
import XCTest
@testable import TaskForce

internal class TaskGroupTests: XCTestCase {
    /// Test a task group with three successfully executing tasks works
    func testTaskGroupWorks() {
        let queue = TaskQueue()
        let groupExpectation = expectation(description: "Waiting for task group to finish.")

        let taskA = MockAdditionTask(x: 1.0, y: 1.0)
        let taskB = MockAdditionTask(x: 2.0, y: 2.0)
        let taskC = MockAdditionTask(x: 3.0, y: 3.0)

        let taskGroup = TaskGroup(tasks: taskA, taskB, taskC)
        taskGroup.completionBlock = { groupExpectation.fulfill() }

        queue.addTask(taskGroup)
        wait(for: [groupExpectation], timeout: 0.2)
    }

    /// Test cancelling a task group cancels all tasks in the group
    func testCancelTaskGroupCancelsAllTasks() {
        let taskA = MockAdditionTask(x: 1.0, y: 1.0)
        let taskB = MockAdditionTask(x: 2.0, y: 2.0)

        let taskGroup = TaskGroup(tasks: taskA, taskB)
        taskGroup.cancel()

        for task in taskGroup.internalQueue.tasks {
            XCTAssertTrue(task.isCancelled)
        }
    }
}
