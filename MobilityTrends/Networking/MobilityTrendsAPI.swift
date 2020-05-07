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
    static let CHANGINGurlPART = "applemobilitytrends-2020-05-05.csv"
    
    static let url = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev49/v2/en-us/applemobilitytrends-2020-05-05.csv")!
    
    
    static func getMobilityData(url: URL) -> AnyPublisher<String, Never> {
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
            .map { CSVParser.parseCSVToTrends(csv: $0) }
            .eraseToAnyPublisher()
    }
}

enum CSVParser {
    
//    static func getMobilityTrends() -> AnyPublisher<[Trend], Never> {
//        MobilityTrendsAPI.getMobilityData(url: MobilityTrendsAPI.url)
//            .map { CSVParser.parseCSVToTrends(csv: $0) }
//            .eraseToAnyPublisher()
//    }
    
    
    static func parseCSVToTrends(csv: String) -> [Trend] {
        guard csv.isNotEmpty else { return [] }
        
        let rows = csv.components(separatedBy: "\n")
        var table = [[String]]()
        
        for row in rows {
            table.append(row.components(separatedBy: ","))
        }
        
        let x = table[0].dropFirst(4)
        
        var trends = [Trend]()
        
        for i in 1..<table.count-1 {
            let row = table[i]
            
            trends.append(Trend(region: row[1],
                                geoType: GeoType(rawValue: row[0])!,
                                transportationType: TransportationType(rawValue: row[2])!,
                                dates: Array(x),
                                series: row.dropFirst(4).map { Double($0) ?? -1 }))
        }
        
        return trends
    }
    
}
