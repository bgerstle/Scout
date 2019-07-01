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

protocol DataLoadable {
    func loadData(
        with: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> Resumable
}

enum URLLoadError : Error {
    case noData,
    unrecognizedResponse(URLResponse?),
    badResponse(HTTPURLResponse)
}

extension URLSession : DataLoadable {
    func loadData(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Resumable {
        return dataTask(with: url, completionHandler: completionHandler)
    }
}

typealias DataLoadableCompletionHandler = (Data?, URLResponse?, Error?) -> Void
