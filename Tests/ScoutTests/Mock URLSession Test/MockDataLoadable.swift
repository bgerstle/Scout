//
//  MockDataLoadable.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 7/1/19.
//

import XCTest

import Scout

class MockResumable : Resumable, Mockable {
    let mock = Mock()

    func resume() {
        try! mock.call.resume()
    }
}

class MockDataLoadable : DataLoadable, Mockable {
    let mock = Mock()

    func loadData(with url: URL, completionHandler: @escaping DataLoadableCompletionHandler) -> Resumable {
        return try! mock.call.loadData(with: url, completionHandler: completionHandler) as! Resumable
    }
}

// conditional conformance of DSL when mockable subject is DataLoadable?
extension FuncDSL {
    @discardableResult
    func to(
        completeWith data: Data?,
        urlResponse: URLResponse?,
        error: Error? = nil,
        resumable: Resumable,
        file: StaticString = #file,
        line: UInt = #line
        ) -> FuncDSL {
        return to { args in
            guard let completionHandler = args[1].value as? DataLoadableCompletionHandler else {
                XCTFail("completion handler has wrong type", file: file, line: line)
                return nil
            }
            completionHandler(data, urlResponse, error)
            return resumable
        }
    }
}
