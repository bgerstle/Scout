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
    typealias DataTaskType = MockResumable

    let mock = Mock()

    func dataTask(with url: URL, completionHandler: @escaping DataLoadableCompletionHandler) -> MockResumable {
        return try! mock.call.dataTask(with: url, completionHandler: completionHandler) as! MockResumable
    }
}
