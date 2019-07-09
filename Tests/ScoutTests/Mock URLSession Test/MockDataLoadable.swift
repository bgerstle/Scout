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
