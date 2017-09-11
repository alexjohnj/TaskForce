//
//  DelayTaskTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 09/09/2017.
//

import Foundation
import XCTest
import TaskForce

internal class DelayTaskTests: XCTestCase {
    /// Test a delay task with a negative time interval finishes immediately
    func testNegativeDelayTaskImmediatelyFinishes() {
        let taskExpectation = expectation(description: "Waiting for task to finish")
        let queue = TaskQueue()
        let delay = Date.distantPast.timeIntervalSinceNow

        let task = DelayTask(delay: delay)
        task.completionBlock = { taskExpectation.fulfill() }

        queue.addTask(task)

        wait(for: [taskExpectation], timeout: 0.1)
    }

    /// Test a DelayTask correctly waits for a given amount of time
    func testDelayTaskCorrectlyDelays() {
        let taskExpectation = expectation(description: "Waiting for task to finish")
        let queue = TaskQueue()

        let delay: TimeInterval = 0.2
        var startTime: Date?
        var finishTime: Date?

        let task = DelayTask(delay: delay)
        let observer = BlockTaskObserver(
            onStart: { _ in startTime = Date() },
            onCompletion: { _, _ in
                finishTime = Date()
                taskExpectation.fulfill()
        })
        task.addObserver(observer)

        queue.addTask(task)
        wait(for: [taskExpectation], timeout: delay + 0.1)

        let measuredDelayTime = finishTime!.timeIntervalSince(startTime!)
        XCTAssertEqual(Int(delay * 10), Int(measuredDelayTime * 10))
    }

    /// Test a DelayTask that is cancelled finishes immediately. Note that if DelayTask stops handling cancellation
    /// of a task before it is started correctly, this method will trigger a runtime warning BUT WILL NOT FAIL. It will
    /// trigger a crash but probably in a different test case. As a result, BE SURE TO CHECK THE CONSOLE FOR WARNINGS.
    func testCancelledDelayTaskImmediatelyFinishes() {
        let taskFinishExpectation = expectation(description: "Waiting for task to finish")
        let queue = TaskQueue()
        queue.isSuspended = true

        let delay = Date.distantFuture.timeIntervalSinceNow
        let task = DelayTask(delay: delay)
        task.completionBlock = {
            taskFinishExpectation.fulfill()
        }

        queue.addTask(task)
        task.cancel()
        queue.isSuspended = false
        wait(for: [taskFinishExpectation], timeout: 0.1)
    }
}
