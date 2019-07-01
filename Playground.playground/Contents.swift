import Foundation

// If you see a "No such module 'Scout'" error, make sure you're building for iOS Simulator.
import Scout

// In this example, we'll be creating a mock for the Animal interface.
protocol Animal {
    var species: String { get }

    func speak() -> String

    func eat(food: String) throws
}

// Since mocking is typically used to test collaboration between components, we'll
// also create a simple Caretaker class which takes care of the animals:
class Caretaker {
    let name: String

    init(name: String) {
        self.name = name
    }

    func talk(to animal: Animal) {
        print("Hey there \(animal.species)! My name's \(name), what's yours?")
        print("\(animal.speak())")
    }

    func feed(animal: Animal, food: String) {
        print("Are you hungry? Let's try some \(food).")
        do {
            try animal.eat(food: food)
            print("Guess so!")
        } catch {
            print("Guess not, we'll take that off the menu.")
        }
    }
}

// Now for the mocking. Instead of hand-rolling a class and creating variables to
// track which functions were called and what the arguments were, we can simply use an
// internal mock to track all of that for us.
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

    // For functions, we use `call`, which works for all kinds of signatures
    // (positional or keyword arguments, throws, void, etc.):
    func speak() -> String {
        // You might notice that we need to do some additional coercion here.
        // Since the mock is completely dynamic, any method can return any type,
        // throw, or not throw. As such, we need to tell the compiler everything
        // will (probably) be ok.
        return try! mock.call.speak() as! String
    }

    // For throwing functions, we use `try` instead of `try!`, since we only want to
    // rethrow any exceptions that were set up in the mock.
    func eat(food: String) throws {
        try mock.call.eat(food: food)
    }
}

let caretaker = Caretaker(name: "Brian")

// Let's start by configuring our MockAnimal to pretend it's a cat:
var mockCat = MockAnimal()
mockCat.expect.species.to(`return`("cat"))
mockCat.expect.speak().to(`return`("meow"))
// Like most cats, we'll ignore the first thing we're offered, hoping for something better.
enum AnimalFeedingErrors : Error {
    case notInterested, barf
}
mockCat.expect.eat(food: any()).toAlways { args in
    // Since we get args as untyped KeyValuePairs, we need to cast it back to the expected type.
    let food = args.first!.value! as! String
    if !food.contains("tuna") {
        throw AnimalFeedingErrors.notInterested
    }
    return ()
}

caretaker.talk(to: mockCat)
caretaker.feed(animal: mockCat, food: "Meow mix")
caretaker.feed(animal: mockCat, food: "Canned tuna")

// Ok, how about an obedient dog that will eat anything?
let mockDog = MockAnimal()
mockDog.expect.species.to(`return`("dog"))
mockDog.expect.speak().to(`return`("woof!"))
mockDog.expect.eat(food: any()).toBeCalled()

caretaker.talk(to: mockDog)
caretaker.feed(animal: mockDog, food: "kibble")
