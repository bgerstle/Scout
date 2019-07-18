//
//  CaretakerTests.swift
//  ExampleProjectTests
//
//  Created by Brian Gerstle on 7/15/19.
//

import XCTest

import Scout

@testable import ExampleProject

class CaretakerTests: XCTestCase {
    var caretaker: Caretaker!
    var mockFoodDepot: MockFoodDepot!

    override func setUp() {
        continueAfterFailure = false

        mockFoodDepot = MockFoodDepot()
        caretaker = Caretaker(name: "Brian", feedStore: mockFoodDepot)
    }

    func testDoesNotCompostFoodThatIsEaten() {
        mockFoodDepot.expect.get().to(`return`(Kibble()))
        let mockDog = MockAnimal()
        mockDog.expect.eat(food: instance(of: Kibble.self)).to(beEaten())

        caretaker.feed(animal: mockDog, foodType: Kibble.self)

        mockFoodDepot.verify()
        mockDog.verify()
    }

    func testCompostsFoodThatIsNotEaten() {
        mockFoodDepot.expect.get()
            .to(`return`(MeowMix()))
            .and
            .to(`return`(Tuna()))

        mockFoodDepot.expect.compost(food: instance(of: MeowMix.self)).toBeCalled()

        let mockCat = MockAnimal()
        mockCat.expect.eat(food: any()).to(onlyEatTuna(), times: 2)

        caretaker.feed(animal: mockCat, foodType: MeowMix.self)
        caretaker.feed(animal: mockCat, foodType: Tuna.self)

        mockFoodDepot.verify()
        mockCat.verify()
    }
}
