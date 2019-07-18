//
//  CaretakerMocks.swift
//  ExampleProjectTests
//
//  Created by Brian Gerstle on 7/16/19.
//

import XCTest
import Scout

@testable import ExampleProject

// MARK: Mocks

class MockAnimal : Animal, Mockable {
    let mock = Mock()

    func eat<T>(_ food: inout T?) {
        let rawResult = try! mock.call.eat(food: food)
        // Avoid using force casting/unwrapping with a mock, since failures will crash your tests.
        // Instead, use guard + XCTFail to report casting failures as test failures.
        guard let eatenFood = rawResult as? T? else {
            XCTFail("Mock should have returned food or nil, got \(String(describing: rawResult))")
            fatalError()
        }
        food = eatenFood
    }
}

class MockFoodDepot: FoodDepot, Mockable {
    let mock = Mock()

    func get<T>() -> T {
        guard let result = try! mock.call.get() as? T else {
            XCTFail("Not expecting result of \(T.self)")
            fatalError()
        }
        return result
    }

    func compost<T>(food: T) {
        try! mock.call.compost(food: food)
    }
}

// MARK: eat() Behaviors

func beEaten() -> FuncExpectationBlock {
    return { _ in
        return nil
    }
}

func onlyEatTuna() -> FuncExpectationBlock {
    return { args in
        // Since we get args as untyped KeyValuePairs, we need to cast it back to the expected type.
        let food = args.first?.value!
        return food is Tuna ? nil : food
    }
}

// MARK: Dummy Food Types

struct Kibble {}
struct MeowMix {}
struct Tuna {}
