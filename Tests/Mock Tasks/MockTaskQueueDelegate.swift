//
//  MockTaskQueueDelegate.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation
import TaskForce

internal class MockTaskQueueDelegate: TaskQueueDelegate {
    var onWillAdd: ((TaskQueue, Task) -> Void)?
    var onDidStart: ((TaskQueue, Task) -> Void)?
    var onDidFinish: ((TaskQueue, Task, [Error]) -> Void)?

    func taskQueue(_ taskQueue: TaskQueue, willAddTask task: Task) {
        onWillAdd?(taskQueue, task)
    }

    func taskQueue(_ taskQueue: TaskQueue, didStartTask task: Task) {
        onDidStart?(taskQueue, task)
    }

    func taskQueue(_ taskQueue: TaskQueue, didFinishTask task: Task, withErrors errors: [Error]) {
        onDidFinish?(taskQueue, task, errors)
    }
}
