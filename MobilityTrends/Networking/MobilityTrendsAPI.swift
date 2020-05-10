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
    
    private static func getURL(for endpoint: Endpoint) -> AnyPublisher<URL, Error> {
        let url = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/current/v2/index.json")!
        
        return URLSession.shared.fetchData(url: url)
            .decode(type: Piece.self, decoder: JSONDecoder())
            .map { $0.url(for: endpoint) }
            .eraseToAnyPublisher()
    }
    
    //  MARK: -
    ///  JSON with Mobility Trends data but without GeoType (less info than in CSV)
    static func fetchMobilityJSON() -> AnyPublisher<Mobility, Error> {
        MobilityTrendsAPI.getURL(for: Endpoint.jsonPath)
            .flatMap { URLSession.shared.fetchData(url: $0) }
            .decode(type: Mobility.self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    //  MARK: -
    ///  JSON locale names (plain string array, no GeoType)
    static func fetchLocaleNamesJSON() -> AnyPublisher<[String], Error> {
        MobilityTrendsAPI.getURL(for: Endpoint.localeNamesPath)
            .flatMap { URLSession.shared.fetchData(url: $0) }
            .decode(type: [String].self, decoder: JSONDecoder())
            .map { $0.sorted() }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    //  MARK: -
    //  CSV (everything, but date in filename makes update tricky)
    static func fetchMobilityCSV() -> AnyPublisher<String, Never> {
        MobilityTrendsAPI.getURL(for: Endpoint.csvPath)
            .flatMap {
                URLSession.shared.dataTaskPublisher(for: $0)
                    .mapError { $0 as Error }
        }
        .map { String(data: $0.data, encoding: .utf8)! }
        .catch { _ in Just("") }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    // MARK: - Piece
    private struct Piece: Codable {
        let basePath, mobilityDataVersion: String
        let lang: Lang
        
        enum CodingKeys: String, CodingKey {
            case basePath, mobilityDataVersion
            case lang = "regions"
        }
        
        // MARK: - Regions
        struct Lang: Codable {
            let enUs: EnUs
            
            enum CodingKeys: String, CodingKey {
                case enUs = "en-us"
            }
        }
        
        // MARK: - EnUs
        struct EnUs: Codable {
            let jsonPath, localeNamesPath, csvPath, initialPath: String
            let shards: Shards
        }
        
        // MARK: - Shards
        struct Shards: Codable {
            let defaults: String
        }
        
        // MARK: - URL
        func url(for endpoint: Endpoint) -> URL {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "covid19-static.cdn-apple.com"
            components.path = self.basePath + self.lang.enUs.csvPath
            
            
            switch endpoint {
            case .csvPath:
                components.path = self.basePath + self.lang.enUs.csvPath
            case .initialPath:
                components.path = self.basePath + self.lang.enUs.initialPath
            case .jsonPath:
                components.path = self.basePath + self.lang.enUs.jsonPath
            case .localeNamesPath:
                components.path = self.basePath + self.lang.enUs.localeNamesPath
            }
            
            return components.url!
        }
    }
    
    private enum Endpoint {
        case jsonPath, localeNamesPath, csvPath, initialPath
    }
    
    
    //  JSON (data, no GeoType)
    private static let urlMobilityJSON = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev51/v2/en-us/applemobilitytrends.json")!
    //  JSON locale names (plain string array, no GeoType)
    private static let urlLocaleNamesJSON = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev51/v2/en-us/locale-names.json")!
    
    //  CSV (everything, but date in filename makes uptade tricky)
    private static let urlMobilityCSV = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev53/v2/en-us/applemobilitytrends-2020-05-08.csv")!
}
