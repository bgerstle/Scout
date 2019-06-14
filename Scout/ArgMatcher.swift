//
//  ArgMatcher.swift
//  Scout
//
//  Created by Brian Gerstle on 6/14/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

public protocol ArgMatcher {
    func matches(arg: Any?) -> Bool
}

public func equalTo<T: Equatable>(_ value: T?) -> ArgMatcher {
    return EqualityMatcher(value: value)
}

class EqualityMatcher<T: Equatable> : ArgMatcher, CustomStringConvertible {
    let value: T?

    init(value: T?) {
        self.value = value
    }

    public func matches(arg: Any?) -> Bool {
        return value == nil && arg == nil || (arg as? T) == value
    }

    public var description: String {
        return "Equal to \(String(describing: value))"
    }
}

public func any() -> ArgMatcher {
    return AnyMatcher()
}

class AnyMatcher : ArgMatcher {
    public func matches(arg: Any?) -> Bool {
        return true
    }
}

public func satisfies(_ predicate: @escaping (Any?) -> Bool) -> ArgMatcher {
    return SatisfiesMatcher(predicate: predicate)
}

class SatisfiesMatcher : ArgMatcher, CustomStringConvertible {
    let predicate: (Any?) -> Bool

    init(predicate: @escaping (Any?) -> Bool) {
        self.predicate = predicate
    }

    public func matches(arg: Any?) -> Bool {
        return predicate(arg)
    }

    public var description: String {
        return "Matching predicate"
    }
}
