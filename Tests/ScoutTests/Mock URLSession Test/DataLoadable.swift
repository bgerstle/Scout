//
//  DataLoadable.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 7/1/19.
//

import Foundation

protocol Resumable {
    func resume()
}

extension URLSessionDataTask : Resumable {}

typealias DataLoadableCompletionHandler = (Data?, URLResponse?, Error?) -> Void

protocol DataLoadable {
    // This associatedtype is necessary, because Swift doesn't consider
    // dataTask -> Resumable == dataTask -> URLSessionDataTask
    associatedtype DataTaskType: Resumable

    func dataTask(
        with: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> DataTaskType
}

enum URLLoadError : Error {
    case
    noData,
    unrecognizedResponse(URLResponse?),
    badResponse(HTTPURLResponse)
}

extension URLSession : DataLoadable {
    typealias DataTaskType = URLSessionDataTask
}
