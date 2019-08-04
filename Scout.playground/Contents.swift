import XCTest
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

 Let's say we're testing the `TestSubject` class, which depends on the `Example` interface:
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

//: Normally, we'd write a custom Mock that looks something like this:

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
 That's all well and good for a couple of mocks, but can get repetitive (and error prone) as you
 start writing more mocks for your tests. This is the problem Scout aims to solve. To see how, we're
 going to create another mock `Example`. First, we'll define our mock class, `MockExample`, and
 declare its conformance to the `Mockable` protocol:
*/

class MockExample : Mockable {
    let mock = Mock()
}

/*:
 Now let's implement the `Example` protocol, but use `mock` to do the heavy lifting.
 To implement the `foo` requirement of the `Example` protocol, we'll use `mock.get` to get
 expected values of `foo`:
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
*/
extension MockExample {
    func baz() {
        try! mock.call.baz()
    }
}

/*:
 Now that we've implemented `foo` and `baz()`, we can make our conformance to the `Example`
 protocol official:
 */
extension MockExample : Example {}

/*:
 Notice the lack of other `var`s and flags inside `MockExample`. All the logic about what to return
 or which functions were called is taken care of by `mock`—including failure reporting if something
 goes wrong. This is accomplished by configuring the mock with expectations.

 ### Setting Expectations

 In general, mocks help us verify that our test subjects behave as expected under certain conditions.
 `Mock` allows us to set up these conditions using the `expect` domain-specific language (DSL).
 Let's write some more tests for our `TestSubject`, using our new `MockExample` to simulate important
 scenarios:
*/

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

/*:
 Instead of setting values on the mock like we did last time, we tell it to `expect` vars to return
 values and for specific functions to be called. You can see this in action if we force the tests
 to fail:
 */

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
 Now that you've seen what Scout can do, why don't you make some changes to the
 `Example` protocol and the `MockExample` class? You can try creating some expectations
 and seeing how they behave below:
 */

let mockExample = MockExample()

mockExample.expect.foo.to(`return`("foo"))
mockExample.foo

func write(logMessage: String) -> FuncExpectationBlock {
    return { _ in
        print(logMessage)
    }
}
mockExample.expect.baz().to(write(logMessage: "Hello world"))
mockExample.baz()

/*:
 You can see more examples of how to use Scout in the ExampleProject tests and
 Scout's own tests. The "Usage" section of the README has some documentation
 in case you forget how a specific method works.

 Happy testing!
 */
