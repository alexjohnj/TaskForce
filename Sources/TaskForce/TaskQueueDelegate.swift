//
//  TaskQueueDelegate.swift
//  TaskForce
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation

public protocol TaskQueueDelegate: class {
    func taskQueue(_ taskQueue: TaskQueue, willAddTask task: Task)
    func taskQueue(_ taskQueue: TaskQueue, didStartTask task: Task)
    func taskQueue(_ taskQueue: TaskQueue, didFinishTask task: Task, withErrors errors: [Error])
}
