//
//  TaskGroup.swift
//  TaskForce
//
//  Created by Alex Jackson on 11/09/2017.
//

import Foundation

public class TaskGroup: Task {
    /// The internal task queue used for the task group.
    lazy internal var internalQueue: TaskQueue = {
        let queue = TaskQueue()
        queue.isSuspended = true
        queue.delegate = self

        return queue
    }()

    /// Task on which all other tasks depend. Ensures submitted tasks start at the same time.
    private let startTask = BlockTask {}

    /// Task which depends on all other tasks.
    private let finishTask = BlockTask {}

    /// Array of errors accumulated from exexcuted tasks
    public var accumulatedErrors = [Error]()

    public convenience init(tasks: Task...) {
        self.init(tasks: tasks)

        internalQueue.addTask(startTask)
    }

    /// Initialise a new task group with an array of tasks.
    public init(tasks: [Task]) {
        super.init()

        tasks.forEach(addTask)
    }

    /// Add a new task to the task group. It is a programmer error to call this when a task group has started.
    public func addTask(_ task: Task) {
        assert(isFinished == false && isExecuting == false, "Can not add tasks to an in-progress or finished TaskGroup")
        internalQueue.addTask(task)
    }

    override public func execute() {
        internalQueue.isSuspended = false
        internalQueue.addTask(finishTask)
    }

    /// Cancel all tasks in the task group.
    override public final func cancel() {
        internalQueue.cancelAllTasks()
        super.cancel()
    }

    /// Called when the task group starts a new task. The default implementation does nothing.
    ///
    /// - parameter task: The task that has been started.
    open func didStartTask(_ task: Task) {
        // Nothing. Subclasses can override
    }

    /// Called when the task group finishes a task. The default implementation does nothing.
    ///
    /// - parameter task: The task that has finished.
    /// - parameter errors: An array of errors that `task` finished with.
    open func didFinishTask(_ task: Task, withErrors errors: [Error]) {
        // Nothing. Subclasses can override
    }
}

extension TaskGroup: TaskQueueDelegate {
    public final func taskQueue(_ taskQueue: TaskQueue, willAddTask task: Task) {
        guard task !== startTask,
            task !== finishTask else {
                return
        }

        task.addDependency(startTask)
        finishTask.addDependency(task)
    }

    public final func taskQueue(_ taskQueue: TaskQueue, didStartTask task: Task) {
        if task !== startTask,
            task !== finishTask {
            didStartTask(task)
        }
    }

    public final func taskQueue(_ taskQueue: TaskQueue, didFinishTask task: Task, withErrors errors: [Error]) {
        accumulatedErrors += errors

        if task !== startTask,
            task !== finishTask {
            didFinishTask(task, withErrors: errors)
        } else if task === finishTask {
            internalQueue.isSuspended = true
            finish(withErrors: accumulatedErrors)
        }
    }
}
