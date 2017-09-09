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
    // MARK: Associated Types

    public enum RequirementError: Error {
        case failed(requirement: TaskRequirement)
    }

    // MARK: Properties
    // Tasks should only be executed from operation queues so these properties are always false.
    override final public var isAsynchronous: Bool { return false }
    override final public var isConcurrent: Bool { return isAsynchronous }

    private var _ready: Bool = false
    override final public var isReady: Bool {
        get {
            return _ready
        }

        set {
            willChangeValue(forKey: "isReady")
            _ready = newValue
            didChangeValue(forKey: "isReady")
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
        super.start()

        if isCancelled {
            finish()
            return
        }
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

    final public func finish(withErrors errors: [Error] = []) {
        observers.forEach { $0.taskDidFinish(self, withErrors: errors) }
    }
}
