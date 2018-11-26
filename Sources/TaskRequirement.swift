//
//  TaskRequirement.swift
//  TaskForce
//
//  Created by Alex Jackson on 08/09/2017.
//

import Foundation

public protocol TaskRequirement {
    func evaluateRequirementForTask(_ task: Task, callback: (TaskRequirementResult) -> Void)
    func requirementDependencyForTask(_ task: Task) -> Task?
}

public enum TaskRequirementResult {
    case satisfied(requirement: TaskRequirement)
    case failed(requirement: TaskRequirement)
}
