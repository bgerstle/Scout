//
//  DataLoadableResultAdapter.swift
//  ScoutTests
//
//  Created by Brian Gerstle on 7/1/19.
//

import Foundation

class DataLoadableResultAdapter {
    typealias ResultHandler = (Result<(Data, URLResponse), Error>) -> Void
    let resultHandler: ResultHandler

    init(resultHandler: @escaping ResultHandler) {
        self.resultHandler = resultHandler
    }

    func complete(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        resultHandler(Result {
            if let error = error {
                throw error
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLLoadError.unrecognizedResponse(response)
            }
            guard httpResponse.statusCode == 200 else {
                throw URLLoadError.badResponse(httpResponse)
            }
            guard let data = data else {
                throw URLLoadError.noData
            }
            return (data, httpResponse)
        })
    }
}

extension DataLoadable {
    func loadData(with url: URL, resultHandler: @escaping DataLoadableResultAdapter.ResultHandler) {
        let adapter = DataLoadableResultAdapter(resultHandler: resultHandler)
        let task: Resumable = loadData(with: url, completionHandler: adapter.complete)
        task.resume()
    }
}
