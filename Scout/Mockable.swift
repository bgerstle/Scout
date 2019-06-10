//
//  Mockable.swift
//  Scout
//
//  Created by Brian Gerstle on 6/10/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public class Mock {
    internal enum VarAction {
        case get(Any?),
        set((Any?) -> Void)
    }

    public init() {
        
    }

    private var varActions: [String: [VarAction]] = [:]

    internal func append(varAction: VarAction, for member: String) {
        varActions[member] = varActions[member, default: []] + [varAction]
    }

    internal func pop(memberAction member: String) -> VarAction {
        guard let actions = varActions[member] else {
            assertionFailure("No actions defined for member \(member)")
            fatalError()
        }
        assert(actions.count > 0, "No more actions defined for \(member)")
        let action = actions[0]
        varActions[member] = Array(actions.suffix(from: 1))
        return action
    }

    public subscript<T>(dynamicMember member: String) -> T! {
        let action = pop(memberAction: member)
        switch action {
        case .get(let value):
            if value == nil {
                return nil
            }
            guard let typedValue = value as? T else {
                assertionFailure("Expected value of type \(T.self) for \(member), got \(type(of: value))")
                return nil
            }
            return typedValue
        default:
            assertionFailure("Not expecting \(action) for member \(member)")
            fatalError()
        }
    }
}

@dynamicMemberLookup
public struct ExpectDSL {
    let mock: Mock

    public struct MemberActionDSL {
        let parent: ExpectDSL
        let member: String

        public func toReturn(_ value: Any?) -> MemberActionDSL {
            parent.mock.append(varAction: .get(value), for: member)
            return self
        }

        public func toReturn(valuesFrom values: [Any?]) -> MemberActionDSL {
            return values.reduce(self) { (_, val) in self.toReturn(val) }
        }

        public var and:  MemberActionDSL {
            return self
        }
    }

    public subscript(dynamicMember member: String) -> MemberActionDSL {
        get {
            return MemberActionDSL(parent: self, member: member)
        }
    }
}

public protocol Mockable {
    var mock: Mock { get }
}

public extension Mockable {
    var expect: ExpectDSL {
        return ExpectDSL(mock: mock)
    }
}

