//
//  CaretakerTests.swift
//  ExampleProjectTests
//
//  Created by Brian Gerstle on 7/15/19.
//

import XCTest

import Scout

@testable import ExampleProject

class MockAnimal : Animal, Mockable {
    // Simply declare a `mock` member and use it
    // in all your protocol method implementations:
    let mock = Mock()

    // Here, we use the `get` DSL to retrieve a `var`:
    var species: String {
        get {
            return mock.get.species
        }
    }

    // For throwing functions, we use `try` instead of `try!`, since we only want to
    // rethrow any exceptions that were set up in the mock.
    func eat<T>(_ food: inout T?) {
        food = try! mock.call.eat(food: food) as! T?
    }
}

class MockFoodDepot: FoodDepot, Mockable {
    let mock = Mock()

    func get<T>() -> T {
        return try! mock.call.get() as! T
    }

    func compost<T>(food: T) {
        try! mock.call.compost(food: food)
    }
}

// eat() Behaviors

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

// Dummy Food Types

struct Kibble {}
struct MeowMix {}
struct Tuna {}

class CaretakerTests: XCTestCase {
    var caretaker: Caretaker!
    var mockFoodDepot: MockFoodDepot!
    var mockAnimal: MockAnimal!

    override func setUp() {
        mockFoodDepot = MockFoodDepot()
        mockAnimal = MockAnimal()
        caretaker = Caretaker(name: "Brian", feedStore: mockFoodDepot)
    }

    func testGetsKibbleFromDepotToFeedDog() {
        mockFoodDepot.expect.get().to(`return`(Kibble()))
        mockAnimal.expect.eat(food: instance(of: Kibble.self)).to(beEaten())

        caretaker.feed(animal: mockAnimal, foodType: Kibble.self)
    }
}
