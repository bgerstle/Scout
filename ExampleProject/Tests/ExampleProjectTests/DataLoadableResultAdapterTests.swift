//
//  DataLoadableResultAdapterTests.swift
//  Scout
//
//  Created by Brian Gerstle on 6/30/19.
//

import XCTest

@testable import ExampleProject

import Scout

class DataLoadableResultAdapterTests : XCTestCase {
    var mockResumable: MockResumable!
    var mockDataLoadable: MockDataLoadable!
    var result: Result<(Data, URLResponse), Error>!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        mockResumable = MockResumable()
        mockDataLoadable = MockDataLoadable()
        result = nil
    }

    func testSuccessfulResult() {
        let url = URL(string: "http://example.com/foo")!,
            data = "foo".data(using: .utf8)!,
            urlResponse = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: nil
            )!

        mockDataLoadable
            .expect
            .dataTask(with: equalTo(url), completionHandler: any())
            .to(complete(withData: data,
                         urlResponse: urlResponse,
                         error: nil))

        let resumable = mockDataLoadable.dataTask(with: url, resultHandler: self.setResult)

        XCTAssert(resumable === mockResumable)

        mockDataLoadable.verify()

        XCTAssertNotNil(result)

        XCTAssertNoThrow(try result.get())
        let (actualData, actualResponse) = try! result.get()

        XCTAssertEqual(actualData, data)

        if let actualHttpUrlResponse = actualResponse as? HTTPURLResponse {
            XCTAssertEqual(actualHttpUrlResponse, urlResponse)
        } else {
            XCTFail("Unexpected response \(actualResponse)")
        }
    }

    func testErrorResult() {
        let url = URL(string: "http://example.com/foo")!,
            error = NSError(
                domain: URLError.errorDomain,
                code: URLError.cannotFindHost.rawValue,
                userInfo: nil
            )

        mockDataLoadable
            .expect
            .dataTask(with: equalTo(url), completionHandler: any())
            .to(complete(withData: nil,
                         urlResponse: nil,
                         error: error))

        let _ = mockDataLoadable.dataTask(with: url, resultHandler: self.setResult)

        mockDataLoadable.verify()

        XCTAssertNotNil(result)

        XCTAssertThrowsError(try result.get()) { actualError in
            XCTAssertEqual((actualError as NSError), error)
        }
    }

    func testServerErrorResponse() {
        let url = URL(string: "http://example.com/foo")!,
            urlResponse = HTTPURLResponse(
                url: url,
                statusCode: 500,
                httpVersion: "1.1",
                headerFields: nil
            )!

        mockDataLoadable
            .expect
            .dataTask(with: equalTo(url), completionHandler: any())
            .to(complete(withData: nil,
                         urlResponse: urlResponse,
                         error: nil))

        let _ = mockDataLoadable.dataTask(with: url, resultHandler: self.setResult)

        mockDataLoadable.verify()

        XCTAssertNotNil(result)

        XCTAssertThrowsError(try result.get()) { actualError in
            guard let actualURLLoadError = actualError as? URLLoadError else {
                XCTFail("Unexpected error \(actualError)")
                return
            }
            if case let URLLoadError.badResponse(actualURLResponse) = actualURLLoadError {
                XCTAssertEqual(actualURLResponse, urlResponse)
            } else {
                XCTFail("Unexpected URLLoadError \(actualURLLoadError)")
            }
        }
    }

    // MARK: - Helpers

    func complete(
        withData data: Data?,
        urlResponse: URLResponse?,
        error: Error? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FuncExpectationBlock {
        return { args in
            guard let completionHandler = args[1].value as? DataLoadableCompletionHandler else {
                XCTFail("completion handler has wrong type", file: file, line: line)
                return nil
            }
            completionHandler(data, urlResponse, error)
            return self.mockResumable
        }
    }


    func setResult(_ result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }
}
