//
//  Ext+Bundle.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 09.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

extension Bundle {
    //  https://bestkora.com/IosDeveloper/modern-networking-in-swift-5-with-urlsession-combine-and-codable/
    ///  Выборка данных Модели <T> из файла в Bundle
    ///  Значительно модифицированный мной
    func fetch<T: Decodable>(_ nameJSON: String, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        
        Just(nameJSON)
            .tryMap { (nameJSON) -> Data in
                guard let path = Bundle.main.path(forResource: nameJSON, ofType: "") else {
                    print("no such file in the Bundle")
                    throw FetchError.noFile
                }
                return FileManager.default.contents(atPath: path)!
        }
//            .flatMap { (nameJSON) -> AnyPublisher<Data, Never> in
//                let path = Bundle.main.path(forResource:nameJSON,
//                                            ofType: "")!
//                let data = FileManager.default.contents(atPath: path)!
//                return Just(data)
//                    .eraseToAnyPublisher()
//        }
        .decode(type: T.self, decoder: decoder)
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
