//
//  ArgMatcher.swift
//  Scout
//
//  Created by Brian Gerstle on 6/14/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

public protocol ArgMatcher : CustomStringConvertible {
    func matches(arg: Any?) -> Bool
}

let `nil` = NilMatcher()

class NilMatcher : ArgMatcher {
    public func matches(arg: Any?) -> Bool {
        return arg == nil
    }

    public var description: String {
        return "nil"
    }
}

public func equalTo<T: Equatable>(_ value: T) -> ArgMatcher {
    return EqualityMatcher(value: value)
}

class EqualityMatcher<T: Equatable> : ArgMatcher {
    let value: T

    init(value: T) {
        self.value = value
    }

    public func matches(arg: Any?) -> Bool {
        return (arg as? T) == value
    }

    public var description: String {
        return "equal to \(String(describing: value))"
    }
}

public func any() -> ArgMatcher {
    return AnyMatcher()
}

class AnyMatcher : ArgMatcher {
    public func matches(arg: Any?) -> Bool {
        return true
    }

    public var description: String {
        return "anything"
    }
}

public func satisfying(_ description: String, _ predicate: @escaping (Any?) -> Bool) -> ArgMatcher {
    return SatisfiesMatcher(description: description, predicate: predicate)
}

class SatisfiesMatcher : ArgMatcher {
    let predicate: (Any?) -> Bool
    let description: String

    init(description: String, predicate: @escaping (Any?) -> Bool) {
        self.predicate = predicate
        self.description = description
    }

    public func matches(arg: Any?) -> Bool {
        return predicate(arg)
    }
}
