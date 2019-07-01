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
        return "argument equal to \(String(describing: value))"
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

public func satisfying<T>(_ description: String, _ predicate: @escaping (T) -> Bool) -> ArgMatcher {
    return SatisfiesMatcher<T>(description: description, predicate: predicate)
}

class SatisfiesMatcher<T> : ArgMatcher {
    let predicate: (T) -> Bool
    let description: String

    init(description: String, predicate: @escaping (T) -> Bool) {
        self.predicate = predicate
        self.description = description
    }

    public func matches(arg: Any?) -> Bool {
        guard let typedArg = arg as? T else {
            return false
        }
        return predicate(typedArg)
    }
}
