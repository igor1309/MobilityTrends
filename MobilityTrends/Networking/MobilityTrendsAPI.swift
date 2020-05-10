//
//  MobilityTrendsAPI.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

//  https://covid19-static.cdn-apple.com/covid19-mobility-data/current/v2/index.json

enum MobilityTrendsAPI {
    
    //  JSON (data, no GeoType)
    private static let urlMobilityJSON = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev51/v2/en-us/applemobilitytrends.json")!
    
    static func fetchMobilityJSON() -> AnyPublisher<Mobility, Error> {
        URLSession.shared.fetchData(url: urlMobilityJSON)
            .decode(type: Mobility.self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    //  JSON locale names (plain string array, no GeoType)
    private static let urlLocaleNamesJSON = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev51/v2/en-us/locale-names.json")!
    
    static func fetchLocaleNamesJSON() -> AnyPublisher<[String], Error> {
        URLSession.shared.fetchData(url: urlLocaleNamesJSON)
            .decode(type: [String].self, decoder: JSONDecoder())
            .map { $0.sorted() }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    //  CSV (everything, but date in filename makes uptade tricky)
    private static let urlMobilityCSV = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev53/v2/en-us/applemobilitytrends-2020-05-08.csv")!
    
    static func fetchMobilityCSV() -> AnyPublisher<String, Never> {
        URLSession.shared.dataTaskPublisher(for: urlMobilityCSV)
            .map { String(data: $0.data, encoding: .utf8)! }
            //  .mapError{ _ in FetchError.genericError }
            .catch { _ in Just("") }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}
