//
//  MobilityTrendsAPI.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

enum MobilityTrendsAPI {
    
    static let base = "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev49/v2/en-us/"
    //  MARK: - CHANGING URL!!!
    static let CHANGINGurlPART = "applemobilitytrends-2020-05-06.csv"
    
    static let urlCSV = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev49/v2/en-us/applemobilitytrends-2020-05-07.csv")!
    static let urlJSON = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev51/v2/en-us/applemobilitytrends.json")!
    
    static func getMobilityDataJSON(url: URL) -> AnyPublisher<Mobility, Error> {
        URLSession.shared.fetchData(url: url)
            .decode(type: Mobility.self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    static func getMobilityDataCSV(url: URL) -> AnyPublisher<String, Never> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { String(data: $0.data, encoding: .utf8)! }
            //  .mapError{ _ in FetchError.genericError }
            .catch { _ in Just("") }
            .eraseToAnyPublisher()
    }
    
    static func getMobilityDataTrends(url: URL) -> AnyPublisher<[Trend], Never> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { String(data: $0.data, encoding: .utf8)! }
            //  .mapError{ _ in FetchError.genericError }
            .catch { _ in Just("") }
            .tryMap { try CSVParser.parseCSVToTrends(csv: $0) }
            .catch { _ in Just([]) }
            .eraseToAnyPublisher()
    }
}
