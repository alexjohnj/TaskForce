//
//  TaskRequirementTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation
import XCTest
import TaskForce

internal class TaskRequirementTests: XCTestCase {
    /// Test tasks with passing requirements execute
    func testTasksWithPassingRequirementsExecute() {
        let taskExecutionExpectation = expectation(description: "Waiting for task execution block to run.")
        let taskFinishExpectation = expectation(description: "Waiting for task completion block to run.")

        let queue = TaskQueue()
        let task = BlockTask { taskExecutionExpectation.fulfill() }
        task.completionBlock = { taskFinishExpectation.fulfill() }

        let reqA = MockPassingRequirement()
        let reqB = MockPassingRequirement()
        task.addRequirements(reqA, reqB)

        queue.addTask(task)
        wait(for: [taskExecutionExpectation, taskFinishExpectation], timeout: 0.5)
    }

    /// Test tasks with only failing requirements don't execute
    func testTasksWithFailingRequirementsDontExecute() {
        let taskFinishExpectation = expectation(description: "Waiting for task completion block to run.")
        let queue = TaskQueue()
        let task = BlockTask { XCTFail("This block should not have been executed.") }
        task.completionBlock = { taskFinishExpectation.fulfill() }

        let reqA = MockFailingRequirement()
        let reqB = MockFailingRequirement()
        task.addRequirements(reqA, reqB)

        queue.addTask(task)
        wait(for: [taskFinishExpectation], timeout: 0.5)
    }

    /// Test tasks with mixed passing and failing requirements don't execute
    func testTasksWithMixedSuccessRequirementsDontExecute() {
        let taskFinishExpectation = expectation(description: "Waiting for task completion block to run.")
        let queue = TaskQueue()
        let task = BlockTask { XCTFail("This block should not have been executed") }
        task.completionBlock = { taskFinishExpectation.fulfill() }

        let reqA = MockPassingRequirement()
        let reqB = MockFailingRequirement()
        task.addRequirements(reqA, reqB)

        queue.addTask(task)
        wait(for: [taskFinishExpectation], timeout: 0.5)
    }

    /// Test tasks with failing requirements forward their errors to observers
    func testTasksWithFailingRequirementsForwardErrors() {
        let taskObsFinishExpectation = expectation(description: "Waiting for observer to be notified of completion.")
        let queue = TaskQueue()
        let task = BlockTask { XCTFail("This block should not have been executed") }

        let observer = BlockTaskObserver(onStart: nil, onCompletion: { _, error in
            XCTAssertEqual(error.count, 1)
            XCTAssertTrue(error[0] is Task.RequirementError)

            taskObsFinishExpectation.fulfill()
        })
        task.addObserver(observer)

        let req = MockFailingRequirement()
        task.addRequirements(req)

        queue.addTask(task)
        wait(for: [taskObsFinishExpectation], timeout: 0.5)
    }

    /// Test requirements with dependencies execute dependencies.
    func testRequirementsWithDependenciesWork() {
        let taskRequirementDepExpectation = expectation(description: "Waiting for task req dependency to execute")
        let taskCompletionExpectation = expectation(description: "Waiting for task to complete")
        let queue = TaskQueue()

        let mainTask = BlockTask { }
        mainTask.completionBlock = { taskCompletionExpectation.fulfill() }

        let reqDependencyTask = BlockTask {
            // Ensure the main task is waiting for the requirement's dependency to complete
            XCTAssertFalse(mainTask.isExecuting)
            XCTAssertFalse(mainTask.isReady)
            taskRequirementDepExpectation.fulfill()
        }
        let req = MockPassingRequirementWithDependency(dependency: reqDependencyTask)
        mainTask.addRequirement(req)

        queue.addTask(mainTask)
        wait(for: [taskRequirementDepExpectation, taskCompletionExpectation], timeout: 0.5)
    }
}
