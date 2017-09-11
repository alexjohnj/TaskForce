//
//  DelayTask.swift
//  TaskForce
//
//  Created by Alex Jackson on 09/09/2017.
//

import Foundation

public class DelayTask: Task {
    public let delay: TimeInterval

    // Properties to track whether the DelayTask has started. These are needed to avoid a runtime exception (and
    // crashes) when a DelayTask is cancelled before it is started by its operation queue. See the cancel() method for
    // some more detail.
    private var startObserver: BlockTaskObserver?
    private var hasStarted = false

    public init(delay: TimeInterval) {
        self.delay = delay

        super.init()

        startObserver = BlockTaskObserver()
        startObserver?.onStart = { [weak self] _ in self?.hasStarted = true }
    }

    override public final func execute() {
        guard delay > 0 else {
            finish()
            return
        }

        let executionTime = DispatchTime.now() + delay

        DispatchQueue.global().asyncAfter(deadline: executionTime) { [weak self] in
            guard self?.isCancelled == false else {
                return
            }

            self?.finish()
        }
    }

    override public final func cancel() {
        super.cancel()

        // We want to end this task immediately if its cancelled, hence why we override `cancel()` to call `finish()`.
        // However, `finish()` sets the `isFinished` property to `true` which triggers a runtime warning and
        // unpredictable behaviour if the task hasn't been started yet. For normal tasks this isn't a problem.
        // Calling cancel simply sets isCancelled = true. When `start()` is called, `finish()` is called and all is
        // fine. For delay tasks, since we are ending the task in `cancel`, we must check that the task has been
        // started to avoid the runtime exception. If the task hasn't been started, the task's lifecycle proceeds like
        // a normal task.
        if hasStarted {
            finish()
        }
    }
}
