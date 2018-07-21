//
//  BlockTask.swift
//  TaskForce
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation

public final class BlockTask: Task {

    // MARK: - Nested Types

    public typealias Body = (Task) -> Void

    // MARK: - Private Properties

    private let block: Body

    // MARK: - Initializers

    /// Instantiates a new task that executes `block` when run.
    ///
    /// - parameter block: A closure accepting the `Task` instance to run with the task.
    ///
    public init(block: @escaping Body) {
        self.block = block

        super.init()
    }
    
    /// Instantiates a new task that executes `block` when run.
    public convenience init(block: @escaping () -> Void) {
        self.init { _ in block() }
    }

    // MARK: - Task Overrides

    override public func execute() {
        block(self)
        finish()
    }
}
