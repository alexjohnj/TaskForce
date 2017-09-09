//
//  BlockTaskObserver.swift
//  TaskForce
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation

/// A lightweight observer that can be used to execute blocks at different points in a `Task`'s lifecycle. The queue the
/// blocks are executed on is not guaranteed.
public class BlockTaskObserver {
    /// A block to execute when a `Task` begins.
    public var onStart: ((Task) -> Void)?
    /// A block to execute when a `Task` finishes.
    public var onFinish: ((Task, [Error]) -> Void)?

    public init(onStart: ((Task) -> Void)? = nil, onCompletion: ((Task, [Error]) -> Void)? = nil) {
        self.onStart = onStart
        self.onFinish = onCompletion
    }
}

extension BlockTaskObserver: TaskObserver {
    public func taskDidStart(_ task: Task) {
        onStart?(task)
    }

    public func taskDidFinish(_ task: Task, withErrors errors: [Error]) {
        onFinish?(task, errors)
    }
}
