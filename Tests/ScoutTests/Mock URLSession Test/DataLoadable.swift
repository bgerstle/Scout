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
    func loadData(
        with: URL,
        completionHandler: @escaping DataLoadableCompletionHandler
    ) -> Resumable
}

enum URLLoadError : Error {
    case
    noData,
    unrecognizedResponse(URLResponse?),
    badResponse(HTTPURLResponse)
}

extension URLSession : DataLoadable {
    func loadData(
        with url: URL,
        completionHandler: @escaping DataLoadableCompletionHandler
    ) -> Resumable {
        return dataTask(with: url, completionHandler: completionHandler)
    }
}
