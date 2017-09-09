//
//  DelayTask.swift
//  TaskForce
//
//  Created by Alex Jackson on 09/09/2017.
//

import Foundation

public class DelayTask: Task {
    public let delay: TimeInterval

    public init(delay: TimeInterval) {
        self.delay = delay
    }

    override public final func execute() {
        guard delay > 0 else {
            finish()
            return
        }

        let executionTime = DispatchTime.now() + delay

        DispatchQueue.global().asyncAfter(deadline: executionTime) {
            guard self.isCancelled == false else {
                return
            }

            self.finish()
        }
    }

    override public final func cancel() {
        super.cancel()

        // End the delay if it's cancelled.
        finish()
    }
}
