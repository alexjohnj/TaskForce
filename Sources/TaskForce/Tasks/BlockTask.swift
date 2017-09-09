//
//  BlockTask.swift
//  TaskForce
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation

public final class BlockTask: Task {
    private let block: (() -> Void)

    public init(block: @escaping (() -> Void)) {
        self.block = block

        super.init()
    }

    override public func execute() {
        block()
        finish()
    }
}
