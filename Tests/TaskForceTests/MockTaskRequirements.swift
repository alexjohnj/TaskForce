//
//  MockTaskRequirements.swift
//  TaskForcePackageDescription
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation
import TaskForce

internal class MockFailingRequirement: TaskRequirement {
    func evaluateRequirementForTask(_ task: Task, callback: (TaskRequirementResult) -> Void) {
        callback(.failed(requirement: self))
    }

    func requirementDependencyForTask(_ task: Task) -> Task? {
        return nil
    }
}

internal class MockPassingRequirement: TaskRequirement {
    func evaluateRequirementForTask(_ task: Task, callback: (TaskRequirementResult) -> Void) {
        callback(.satisfied(requirement: self))
    }

    func requirementDependencyForTask(_ task: Task) -> Task? {
        return nil
    }
}

internal class MockPassingRequirementWithDependency: TaskRequirement {
    let dependency: Task

    init(dependency: Task) {
        self.dependency = dependency
    }

    func evaluateRequirementForTask(_ task: Task, callback: (TaskRequirementResult) -> Void) {
        callback(.satisfied(requirement: self))
    }

    func requirementDependencyForTask(_ task: Task) -> Task? {
        return dependency
    }
}
