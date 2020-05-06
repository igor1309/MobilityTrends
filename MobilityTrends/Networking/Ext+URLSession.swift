//
//  Ext+URLSession.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

enum FetchError: Error {
    case responseError((status: Int, message: String))
    case emptyResponse
    case genericError
}


extension URLSession {
    
    /// Returns a publisher that transforms a dataTaskPublisher for a given URL with Error (FetchError)
    func fetchData(url: URL) -> AnyPublisher<Data, Error> {
        dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                    200...299 ~= httpResponse.statusCode else {
                        throw FetchError.responseError(
                            ((response as? HTTPURLResponse)?.statusCode ?? 500,
                             String(data: data, encoding: .utf8) ?? ""))
                }
                
                return data
        }
        .eraseToAnyPublisher()
    }
}
