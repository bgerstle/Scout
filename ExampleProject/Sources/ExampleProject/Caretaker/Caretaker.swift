//
//  Caretaker.swift
//  ExampleProject
//
//  Created by Brian Gerstle on 7/15/19.
//

import Foundation

protocol Animal {
    func eat<T>(_ food: inout T?)
}

protocol FoodDepot: class {
    func get<T>() -> T

    func compost<T>(food: T)
}

class Caretaker {
    let feedStore: FoodDepot

    init(feedStore: FoodDepot) {
        self.feedStore = feedStore
    }

    func feed<FoodType>(animal: Animal, foodType: FoodType.Type) {
        var food: FoodType? = feedStore.get()

        animal.eat(&food)

        if food != nil {
            feedStore.compost(food: food)
        }
    }
}
