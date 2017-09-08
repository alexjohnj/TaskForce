//
//  MockAdditionTask.swift
//  TaskForceTests
//
//  Created by Alex Jackson on 2017-09-07.
//

import Foundation
import TaskForce

// swiftlint:disable identifier_name
internal class MockAdditionTask: Task {
    let x: Double
    let y: Double
    var result: Double?

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    override func execute() {
        if isCancelled {
            finish()
            return
        } else {
            result = x + y
            finish()
        }
    }
}
