import Foundation
import Scout

// Now for some fun with XCTest in playgrounds...
func runTests(inClass testClass: XCTestCase.Type) -> XCTestRun {
    let suite = XCTestSuite(forTestCaseClass: testClass)
    suite.run()
    return suite.testRun!
}


/*:
 To use this playground:

 1. Generate Scout's Xcode project: `swift package generate-xcodeproj`
 1. Open `Scout.xcworkspace`
 1. Change the build destination to an iOS simulator
 1. Run the Playground!
 1. _Optional: Enable "Show Rendered Markup" in the "Editor" menu bar drop-down_
*/

/*:
 ## Getting Started

 Scout is designed to facilitate three things:

 1. Writing mocks
 2. Configuring mocks with expected behaviors
 3. Asserting that all expected behaviors were exercised

 ### Writing Mocks
 Writing mocks with Scout involves 3 steps:

 1. Create a class that conforms to the protocol being mocked, plus the `Mockable` protocol
 1. Implement the `Mockable` protocol by adding a `mock` member to your mock class
 1. Implement your protocol, using `mock` as the underlying implementation

 For example, if we are building something that depends on the `Example` interface, we must create a `MockExample`
 to test it:
*/

protocol Example {
    var foo: String { get }

    func baz()
}

class TestSubject {
    let example: Example

    required init(example: Example) {
        self.example = example
    }

    func doAThing() {
        if example.foo == "baz" {
            example.baz()
        }
    }
}

//: Normally, we'd write something like this:

class ManualMockExample: Example {
    var foo: String

    var bazWasCalled: Bool = false

    init(foo: String) {
        self.foo = foo
    }

    func baz() {
        bazWasCalled = true
    }
}

class ManualMockExampleTests : XCTestCase {
    func testBoilerplateIsTedious() {
        let manualMock = ManualMockExample(foo: "baz")
        let testSubject = TestSubject(example: manualMock)

        testSubject.doAThing()

        XCTAssertTrue(manualMock.bazWasCalled)
    }
}

runTests(inClass: ManualMockExampleTests.self)

/*:
 That's all well and good for a couple of mocks, but it gets old after a while.
*/


//: First, we'll declare our `MockExample` and make it `Mockable`:

class MockExample : Mockable {
    let mock = Mock()
}

/*:
 Now let's implement the `Example` protocol, but use `mock` to do the heavy lifting.
 To implement the `foo` requirement of the `Example` protocol, we'll use `mock.get` to get expected values of `foo`:
*/
extension MockExample {
    var foo: String {
        get {
            return mock.get.foo
        }
    }
}

/*:
 For `baz()`, we'll use `mock.call` to return any expected values (or side effects).
 (We'll talk about why `try!` is there later.)
*/
extension MockExample {
    func baz() {
        try! mock.call.baz()
    }
}

//: Now that we've implemented `foo` and `baz()`, we can make our conformance to the `Example` protocol official:
extension MockExample : Example {}

/*:
 Notice we didn't need to (re)implement a bunch of logic for checking whether `foo` was used or
 setting internal flags to indicate `baz()` was called? The `mock` does all of that for us, and will
 record a test failure if something goes wrong. This is done by configuring it with expectations.

 ### Configuring Mocks

 In general, mocks help us verify that our test subjects behave as expected under certain conditions.
 `Mock` allows us to set up these conditions using the `expect` domain-specific language (DSL). Let's go back to our `TestSubject` from earlier, and see how we can test it using the `MockExample` we created:
*/

import XCTest

class TestSubjectTests : XCTestCase {
    var mockExample: MockExample!
    var testSubject: TestSubject!

    override func setUp() {
        mockExample = MockExample()
        createTestSubject()
    }

    func createTestSubject() {
        testSubject = TestSubject(example: mockExample)
    }

    func testCallsBazIfFooIsBaz() {
        mockExample.expect.foo.to(`return`("baz"))
        mockExample.expect.baz().toBeCalled()

        testSubject.doAThing()

        mockExample.verify()
    }

    func testDoesNotCallBazIfFooIsBar() {
        mockExample.expect.foo.to(`return`("bar"))

        testSubject.doAThing()

        mockExample.verify()
    }
}

runTests(inClass: TestSubjectTests.self)

//: Those look nice, but what happens if there's a bug in the test subject?

class BrokenSubjectTests : TestSubjectTests {
    class BrokenTestSubject : TestSubject {
        override func doAThing() {
            if example.foo == "bar" {
                example.baz()
            }
        }
    }

    override func createTestSubject() {
        testSubject = BrokenTestSubject(example: mockExample)
    }
}

runTests(inClass: BrokenSubjectTests.self)

/*:
 Hopefully that's enough to get you started writing and using mocks with Scout. Check out the
 ExampleProject tests and Scout's own tests for more examples of setting different kinds of
 expectations with different kinds of functions. Happy testing!
 */
