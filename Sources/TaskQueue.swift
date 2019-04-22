//
//  TaskQueue.swift
//  TaskForce
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation

public final class TaskQueue {
    // MARK: Obtaining Task Queues
    /// The task queue associated with the main thread.
    public static var main = TaskQueue(operationQueue: .main)

    /// When used from within a `Task`, returns the `TaskQueue` the `Task` is running on. Otherwise it (probably)
    /// returns `nil`.
    public class var current: TaskQueue? {
        return OperationQueue.current == nil ? nil : TaskQueue(operationQueue: OperationQueue.current!)
    }

    /// The `OperationQueue` backing the TaskQueue
    internal let operationQueue: OperationQueue

    public init(operationQueue: OperationQueue = OperationQueue()) {
        self.operationQueue = operationQueue
    }

    // MARK: - Queue Properties

    public weak var delegate: TaskQueueDelegate?

    /** A runtime identifier for the queue. The backing operation queue will be given the same name. */
    public var name: String? {
        get { return operationQueue.name }
        set { operationQueue.name = newValue }
    }

    /**
     Bool controlling how eagerly the queue executes operations. A value of `false` means tasks are executed as soon
     as they are ready.
     */
    public var isSuspended: Bool {
        get { return operationQueue.isSuspended }
        set { operationQueue.isSuspended = newValue }
    }

    /**
     An array of tasks currently in the queue.

     - Note:
     If the backing `OperationQueue` also contains `Operation`s, these will be filtered from the returned array.
     */
    public var tasks: [Task] {
        // swiftlint:disable:next force_cast
        return operationQueue.operations.filter { $0 is Task } as! [Task]
    }

    /** The number of tasks in the queue.

     - Note:
     If the backing `OperationQueue` also contains `Operation`s, these will be filtered from the returned count.
     */
    public var taskCount: Int {
        return tasks.count
    }

    /** The default service level to apply to tasks in the task queue. */
    public var qualityOfService: QualityOfService {
        get { return operationQueue.qualityOfService }
        set { operationQueue.qualityOfService = newValue }
    }

    /** The maximum number of concurrently executing tasks allowed. */
    public var maxConcurrentTaskCount: Int {
        get { return operationQueue.maxConcurrentOperationCount }
        set { operationQueue.maxConcurrentOperationCount = newValue }
    }

    // MARK: - Queue Management
    public func addTask(_ task: Task) {
        // Configure observer for task start and finish delegate methods.
        let taskLifecycleObserver = BlockTaskObserver(
            onStart: { [weak self] task in
                if let strongSelf = self {
                    strongSelf.delegate?.taskQueue(strongSelf, didStartTask: task)
                }
            },
            onCompletion: { [weak self] (task, errors) in
                if let strongSelf = self {
                    strongSelf.delegate?.taskQueue(strongSelf, didFinishTask: task, withErrors: errors)
                }
            })

        task.addObserver(taskLifecycleObserver)

        // Set up requirement dependency tasks
        let requirementDeps = task.requirements.compactMap { $0.requirementDependencyForTask(task) }
        requirementDeps.forEach {
            task.addDependency($0)
            addTask($0)
        }

        delegate?.taskQueue(self, willAddTask: task)
        task.willEnqueue()
        operationQueue.addOperation(task)
    }

    public func addTasks(_ tasks: [Task]) {
        tasks.forEach { self.addTask($0) }
    }

    public func addTasks(_ tasks: Task...) {
        addTasks(tasks)
    }

    public func addTask(_ block: @escaping () -> Void) {
        let task = BlockTask(block: block)
        addTask(task)
    }

    /**
     Cancels all queued and executing tasks in the queue. Any `Operation` subclasses on the backing queue won't be
     cancelled.
     */
    public func cancelAllTasks() {
        tasks.forEach { $0.cancel() }
    }

    /// Blocks the current thread until all enqueued tasks and operations finish.
    ///
    public func waitUntilAllOperationsAreFinished() {
        operationQueue.waitUntilAllOperationsAreFinished()
    }
}

extension TaskQueue: Equatable {
    public static func == (lhs: TaskQueue, rhs: TaskQueue) -> Bool {
        return lhs.operationQueue == rhs.operationQueue
    }
}

extension TaskQueue: Hashable {

    public func hash(into hasher: inout Hasher) {
        operationQueue.hash(into: &hasher)
    }
}
