//
//  TaskQueueDelegateTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation
import XCTest
@testable import TaskForce

internal class TaskQueueDelegateTests: XCTestCase {
    func testTaskQueueNotifiesDelegateOfNewTasks() {
        let delegateExpectation = expectation(description: "Waiting for delegate willAdd method to be called")
        let delegate = MockTaskQueueDelegate()
        delegate.onWillAdd = { _, _ in
            delegateExpectation.fulfill()
        }

        let queue = TaskQueue()
        queue.delegate = delegate

        queue.addTask { }
        wait(for: [delegateExpectation], timeout: 0.5)
    }

    func testTaskQueueNotifiesDelegateWhenStartingTasks() {
        let delegateExpectation = expectation(description: "Waiting for delegate didStart method to be called")
        let delegate = MockTaskQueueDelegate()
        delegate.onDidStart = { _, _ in
            delegateExpectation.fulfill()
        }

        let queue = TaskQueue()
        queue.delegate = delegate

        queue.addTask { }
        wait(for: [delegateExpectation], timeout: 0.5)
    }

    func testTaskQueueNotifiesDelegateWhenCompletingTasks() {
        let delegateExpectation = expectation(description: "Waiting for delegate didFinish method to be called")
        let delegate = MockTaskQueueDelegate()
        delegate.onDidFinish = { _, _, _ in
            delegateExpectation.fulfill()
        }

        let queue = TaskQueue()
        queue.delegate = delegate

        queue.addTask { }
        wait(for: [delegateExpectation], timeout: 0.5)
    }
}
