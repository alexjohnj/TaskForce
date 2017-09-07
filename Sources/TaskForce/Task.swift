//
//  Task.swift
//  TaskForce
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation

/** `Task` is a direct subclass of `Operation` that implements support for observers and task conditions. Users should
 subclass `Task` to create their own tasks, overriding the `execute()` method to imlpement their task's logic.
 **/
open class Task: Operation {
    // MARK: Properties
    // Tasks should only be executed from operation queues so these properties are always false.
    override final public var isAsynchronous: Bool { return false }
    override final public var isConcurrent: Bool { return isAsynchronous }

    // MARK: - Operation Lifecycle
    override final public func start() {
        super.start()

        if isCancelled {
            finish()
            return
        }
    }

    override final public func main() {
        if isCancelled {
            finish()
        } else {
            execute()
        }
    }

    open func execute() {
        fatalError("\(type(of: self)) must override execute() and not call super")
    }

    final public func finish() {
        // Will handle observers
    }
}
