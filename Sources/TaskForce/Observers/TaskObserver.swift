//
//  TaskObserver.swift
//  TaskForce
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation

/// The task observer protocol declares methods that can be used to track the lifecylce of a task.
public protocol TaskObserver: class {
    /// Called when a `Task` begins execution.
    func taskDidStart(_ task: Task)
    /// Called when a `Task` finishes.
    func taskDidFinish(_ task: Task, withErrors errors: [Error])
}
