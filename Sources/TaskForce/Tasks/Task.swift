//
//  Task.swift
//  TaskForce
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation

/**
 `Task` is a subclass of `Operation` that implements support for observers and task requirements. Like `Operation`,
 `Task` should be subclassed to implement the logic of your task. Although `Task`s can be submitted to an
 `OperationQueue`, the `TaskQueue` class provides the extra logic needed for observers and task requirements to work and
 should be used instead.

 # Subclassing

 When subclassing, override the `execute()` method to implement the logic of your task. **Do not** call
 `super.execute()`. `Task` is designed to be an asynchronous subclass of `Operation` (contrary to the `isAsynchronous`
 property's value). As a result, when `execute()` returns, your task will continue executing. You **must** call
 `finish(withErrors:)` at some point to inform the `TaskQueue` and any observers that the task has finished.

 # Task Observer

 An observer is any type that conforms to the `TaskObserver` protocol. Observers are notified when a task's `execute()`
 method is started and when a task's `finish(withErrors:)` method is called. Observers can be added to a task using the
 `addObserver(_:)` and `addObservers(_:)` methods. Adding the same observer multiple times will result in duplicate
 notifications from the task. Once added, an observer can not be removed.

 # Task Requirements

 A requirement is any type that conforms to the `TaskRequirement` protocol. Requirements can be added to a task using
 the `addRequirement(_:)` and `addRequirements(_:)` methods. It is a programmer error (i.e., triggers an assertion) to
 add requirements once a task is executing or has finished. Once a requirement has been added, it can not be removed.

 Requirements are evaluated before a task is added to a `TaskQueue`. If any requirement isn't satisfied, the task will
 finish immediately and an array of `RequirementError`s will be passed to any interested observers.

 **Note**: A `Task` with unsatisfied requirements will *not* be marked as cancelled.
 */
open class Task: Operation {
    // MARK: Associated Types

    public enum RequirementError: Error {
        case failed(requirement: TaskRequirement)
    }

    // MARK: Properties
    // Tasks should only be executed from operation queues so these properties are always false.
    override final public var isAsynchronous: Bool { return false }
    override final public var isConcurrent: Bool { return isAsynchronous }

    private var _ready: Bool = false
    override final public private(set) var isReady: Bool {
        get {
            return _ready
        }

        set {
            willChangeValue(forKey: "isReady")
            _ready = newValue
            didChangeValue(forKey: "isReady")
        }
    }

    private var _finished = false
    override final public private(set) var isFinished: Bool {
        get {
            return _finished
        }

        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    private var _executing = false
    override final public private(set) var isExecuting: Bool {
        get {
            return _executing
        }

        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    // MARK: - Observers
    public private(set) var observers: [TaskObserver] = []

    /**
     Adds an observer to the task. `observer` will be notified at various points during the task's lifecycle. Adding
     the same observer multiple times will result in duplicate notifications of the task's lifecycle.
     */
    public final func addObserver(_ observer: TaskObserver) {
        observers.append(observer)
    }

    public final func addObservers(_ observers: TaskObserver...) {
        addObservers(observers)
    }

    public final func addObservers(_ observers: [TaskObserver]) {
        observers.forEach { self.addObserver($0) }
    }

    // MARK: - Requirements
    /// Array of requirements that must be satisfied before a task can be executed.
    public private(set) var requirements: [TaskRequirement] = []

  /// Array of accumulated errors due to failing requirements
    private var requirementsErrors: [Error] = []

    private func evaluateRequirements(_ requirements: [TaskRequirement], callback: @escaping ([Error]) -> Void) {
        let group = DispatchGroup()
        var results: [TaskRequirementResult] = []

        for requirement in requirements {
            group.enter()
            requirement.evaluateRequirementForTask(self) { result in
                results.append(result)
                group.leave()
            }
        }

        group.notify(queue: .global()) {
            var failedRequirements: [RequirementError] = []
            for result in results {
                if case .failed(let requirement) = result {
                    failedRequirements.append(RequirementError.failed(requirement: requirement))
                }
            }

            callback(failedRequirements)
        }
    }

    public final func addRequirement(_ requirement: TaskRequirement) {
        assert(isExecuting == false, "Attempt to add requirements to an executing task.")
        assert(isFinished == false, "Attempt to add requirements to a finished task.")

        requirements.append(requirement)
    }

    public final func addRequirements(_ requirements: [TaskRequirement]) {
        requirements.forEach { self.requirements.append($0) }
    }

    public final func addRequirements(_ requirements: TaskRequirement...) {
        addRequirements(requirements)
    }

    // MARK: - Operation Lifecycle

    /// Call when a Task is about to be added to a TaskQueue
    internal final func willEnqueue() {
        if requirements.isEmpty {
            isReady = true
        } else {
            evaluateRequirements(requirements) { [weak self] errors in
                self?.requirementsErrors.append(contentsOf: errors)
                self?.isReady = true
            }
        }
    }

    override final public func start() {
        // Return without doing anything if the task has already finished
        guard isFinished == false else {
            return
        }

        // Finish immediately if the task was cancelled
        guard isCancelled == false else {
            finish()
            return
        }

        isExecuting = true
        main()
    }

    override final public func main() {
        guard isCancelled == false,
            requirementsErrors.isEmpty == true else {
                finish(withErrors: requirementsErrors)
                return
        }

        observers.forEach { $0.taskDidStart(self) }
        execute()
    }

    open func execute() {
        fatalError("\(type(of: self)) must override execute() and not call super")
    }

    /// Finish execution of the Task and notify any observers. Subclassers must remember to call super.
    open func finish(withErrors errors: [Error] = []) {
        isExecuting = false
        isFinished = true

        observers.forEach { $0.taskDidFinish(self, withErrors: errors) }
    }
}
