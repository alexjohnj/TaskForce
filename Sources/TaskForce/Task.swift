//
//  Task.swift
//  TaskForce
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation

/**
 `Task` is a direct subclass of `Operation` that implements support for observers and task conditions. Users should
 subclass `Task` to create their own tasks, overriding the `execute()` method to imlpement their task's logic.
 */
open class Task: Operation {
    // MARK: Properties
    // Tasks should only be executed from operation queues so these properties are always false.
    override final public var isAsynchronous: Bool { return false }
    override final public var isConcurrent: Bool { return isAsynchronous }

    // MARK: - Observers
    private var observers: [TaskObserver] = []

    /** Adds an observer to the task. `observer` will be notified at various points during the task's lifecycle. Adding
     the same observer multiple times will result in duplicate notifications of the task's lifecycle. */
    public final func addObserver(_ observer: TaskObserver) {
        observers.append(observer)
    }

    public final func addObservers(_ observers: TaskObserver...) {
        addObservers(observers)
    }

    public final func addObservers(_ observers: [TaskObserver]) {
        observers.forEach { self.addObserver($0) }
    }

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
            observers.forEach { $0.taskDidStart(self) }
            execute()
        }
    }

    open func execute() {
        fatalError("\(type(of: self)) must override execute() and not call super")
    }

    final public func finish(withErrors errors: [Error] = []) {
        observers.forEach { $0.taskDidFinish(self, withErrors: errors) }
    }
}
