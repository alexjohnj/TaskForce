//
//  TaskObserverTests.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation
import XCTest
@testable import TaskForce

internal class TaskObserverTests: XCTestCase {
    /// Test observer's taskDidStart(_:) method is called
    func testTaskObserverInformedOfStart() {
        let testExpect = expectation(description: "Waiting for observer's didStart notification")
        let opQueue = TaskQueue()
        let task = MockAdditionTask(x: 5.0, y: 5.0)

        let observer = BlockTaskObserver()
        observer.onStart = { _ in testExpect.fulfill() }
        task.addObserver(observer)

        opQueue.addTask(task)

        wait(for: [testExpect], timeout: 0.5)
    }

    /// Test observer's taskDidFinish(_:withErrors:) method is called
    func testTaskObserverInformedOfFinish() {
        let testExpect = expectation(description: "Waiting for observer's didFinish notification")
        let opQueue = TaskQueue()
        let task = MockAdditionTask(x: 5.0, y: 5.0)

        let observer = BlockTaskObserver()
        observer.onFinish = { (_, _) in testExpect.fulfill() }
        task.addObserver(observer)

        opQueue.addTask(task)
        wait(for: [testExpect], timeout: 0.5)
    }

    /// Test adding multiple observers results in all observer's being notified.
    func testMultipleObserversAreNotified() {
        let observerAStartExpect = expectation(description: "Waiting for observerA didStart notification")
        let observerAFinishExpect = expectation(description: "Waiting for observerA didFinish notification")
        let observerBStartExpect = expectation(description: "Waiting for observerB didStart notification")
        let observerBFinishExpect = expectation(description: "Waiting for observerB didFinish notification")

        let opQueue = TaskQueue()
        let task = MockAdditionTask(x: 5.0, y: 5.0)

        let observerA = BlockTaskObserver(onStart: { _ in observerAStartExpect.fulfill() },
                                          onCompletion: { (_, _) in observerAFinishExpect.fulfill() })
        let observerB = BlockTaskObserver(onStart: { _ in observerBStartExpect.fulfill() },
                                          onCompletion: { (_, _) in observerBFinishExpect.fulfill() })

        task.addObservers(observerA, observerB)

        opQueue.addTask(task)
        wait(for: [observerAStartExpect, observerAFinishExpect, observerBStartExpect, observerBFinishExpect],
             timeout: 0.5)
    }
}
