//
//  MockURLSessionTests.swift
//  Scout
//
//  Created by Brian Gerstle on 6/30/19.
//

import XCTest

import Scout

class MockURLSessionTests : XCTestCase {
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

    func setResult(_ result: Result<(Data, URLResponse), Error>) {
        self.result = result
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

        mockResumable
            .expect
            .resume()
            .toBeCalled()

        mockDataLoadable
            .expect
            .loadData(with: equalTo(url), completionHandler: any())
            .to(completeWith: data, urlResponse: urlResponse, resumable: mockResumable)

        mockDataLoadable.loadData(with: url, resultHandler: self.setResult)

        mockResumable.assertNoExpectationsRemaining()
        mockDataLoadable.assertNoExpectationsRemaining()

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

        mockResumable
            .expect
            .resume()
            .toBeCalled()

        mockDataLoadable
            .expect
            .loadData(with: equalTo(url), completionHandler: any())
            .to(completeWith: nil, urlResponse: nil, error: error, resumable: mockResumable)

        mockDataLoadable.loadData(with: url, resultHandler: self.setResult)

        mockResumable.assertNoExpectationsRemaining()
        mockDataLoadable.assertNoExpectationsRemaining()

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

        mockResumable
            .expect
            .resume()
            .toBeCalled()

        mockDataLoadable
            .expect
            .loadData(with: equalTo(url), completionHandler: any())
            .to(completeWith: nil, urlResponse: urlResponse, error: nil, resumable: mockResumable)

        mockDataLoadable.loadData(with: url, resultHandler: self.setResult)

        mockResumable.assertNoExpectationsRemaining()
        mockDataLoadable.assertNoExpectationsRemaining()

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
}
