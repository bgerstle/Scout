//
//  MockExample.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 6/29/19.
//

import Foundation

import Scout

protocol Example {
    var strVar: String { get }

    func nullaryFunc() -> String

    var varGetter: Int { get }

    func voidNullaryThrows() throws

    func unaryThrows(arg: String) throws

    func voidPositional(_ value: Int)

    func voidMixedKwPosArgs(kwarg: String, _ posValue: Int)

    func mixedKwPosArgs(kwarg: String, _ posValue: Int) -> String

    func optionalArg(_ value: Int?)
}

struct ExampleError : Error { }

class MockExample : Example, Mockable {
    let mock = Mock()

    var strVar: String {
        get {
            return mock.get.strVar
        }
    }

    var varGetter: Int {
        get {
            // defaulting to empty string since failures need to be recorded w/o crashing
            return mock.get.varGetter ?? 0
        }
    }

    func nullaryFunc() -> String {
        return try! mock.call.nullaryFunc() as! String
    }

    func voidPositional(_ value: Int) {
        try! mock.call.voidPositional(value)
    }

    func voidNullaryThrows() throws {
        try mock.call.voidNullaryThrows()
    }

    func voidMixedKwPosArgs(kwarg: String, _ posValue: Int) {
        try! mock.call.voidMixedKwPosArgs(kwarg: kwarg, posValue)
    }

    func mixedKwPosArgs(kwarg: String, _ posValue: Int) -> String {
        // defaulting to empty string since failures need to be recorded w/o crashing
        return try! mock.call.mixedKwPosArgs(kwarg: kwarg, posValue) as? String ?? ""
    }

    func unaryThrows(arg: String) throws {
        try mock.call.unaryThrows(arg: arg)
    }

    func optionalArg(_ value: Int?) {
        try! mock.call.optionalArg(value)
    }
}
