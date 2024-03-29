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

class MobilityTrendsAPI {
    static let shared = MobilityTrendsAPI()
    
    private init() { }
    
    func ping(version: Int) -> AnyPublisher<String, Never> {
        fetchURL(for: Endpoint.csvPath, version: version)
            .map { $0.absoluteString }
            .replaceError(with: "Error fetching data")
            .eraseToAnyPublisher()
    }
    
    private func fetchURL(for endpoint: Endpoint, version: Int) -> AnyPublisher<URL, Error> {
        let url = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/current/v\(version)/index.json")!
        
        return URLSession.shared.fetchData(url: url)
            .decode(type: Piece.self, decoder: JSONDecoder())
            .map {
                let url = $0.url(for: endpoint)
                //  print("fetchURL: \(url)")
                return url
        }
        .eraseToAnyPublisher()
    }
    
    //  MARK: - fetch()
    
    //  MARK: CSV
    
    /// never fails, emits MobilityData with empty [] sources and regions if empty response or upstream Error (network or parsing)
    func fetchMobilityDataWithEmpty(version: Int) -> AnyPublisher<MobilityData, Never> {
        fetchURL(for: Endpoint.csvPath, version: version)
            .flatMap {
                URLSession.shared.dataTaskPublisher(for: $0)
                    .mapError { $0 as Error }
        }
        .map { String(data: $0.data, encoding: .utf8)! }
        .tryMap { try CSVParser.parseCSVToMobilityData(csv: $0) }
        .catch { _ in Just(MobilityData(sources: [], regions: [])) }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    
    /// emits non-empty [Source]
    func fetchMobility(version: Int) -> AnyPublisher<[Source], Never> {
        fetchURL(for: Endpoint.csvPath, version: version)
            .flatMap {
                URLSession.shared.dataTaskPublisher(for: $0)
                    .mapError { $0 as Error }
        }
        .map { String(data: $0.data, encoding: .utf8)! }
        .tryMap { try CSVParser.parseCSVToSources(csv: $0) }
        .filter { $0.isNotEmpty }
        .catch { _ in
            Empty(completeImmediately: true)
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    /// emits [Source] with empty [] if empty response or Error
    func fetchMobilityWithEmpty(version: Int) -> AnyPublisher<[Source], Never> {
        fetchURL(for: Endpoint.csvPath, version: version)
            .flatMap {
                URLSession.shared.dataTaskPublisher(for: $0)
                    .mapError { $0 as Error }
        }
        .map { String(data: $0.data, encoding: .utf8)! }
        .tryMap { try CSVParser.parseCSVToSources(csv: $0) }
        .catch { _ in Just([]) }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    /// emits non-empty  territories: [Region]
    func fetchTerritories(version: Int) -> AnyPublisher<[Region], Never> {
        fetchURL(for: Endpoint.csvPath, version: version)
            .flatMap {
                URLSession.shared.dataTaskPublisher(for: $0)
                    .mapError { $0 as Error }
        }
        .map { String(data: $0.data, encoding: .utf8)! }
        .tryMap { try CSVParser.parseCSVToRegions(csv: $0) }
        .filter { $0.isNotEmpty }
        .catch { _ in
            Empty(completeImmediately: true)
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    /// emits territories: [Region] - empty id emty response or Error
    func fetchTerritoriesWithEmpty(version: Int) -> AnyPublisher<[Region], Never> {
        fetchURL(for: Endpoint.csvPath, version: version)
            .flatMap {
                URLSession.shared.dataTaskPublisher(for: $0)
                    .mapError { $0 as Error }
        }
        .map { String(data: $0.data, encoding: .utf8)! }
        .tryMap { try CSVParser.parseCSVToRegions(csv: $0) }
        .catch { _ in Just([]) }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    

    //  MARK: - JSON - NOT USED
    ///  JSON with Mobility Trends data but without GeoType (less info than in CSV)
    func fetchMobilityJSON(version: Int) -> AnyPublisher<Mobility, Error> {
        fetchURL(for: Endpoint.jsonPath, version: version)
            .flatMap { URLSession.shared.fetchData(url: $0) }
            .decode(type: Mobility.self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    ///  JSON locale names (plain string array, no GeoType)
    func fetchLocaleNamesJSON(version: Int) -> AnyPublisher<[String], Error> {
        fetchURL(for: Endpoint.localeNamesPath, version: version)
            .flatMap { URLSession.shared.fetchData(url: $0) }
            .decode(type: [String].self, decoder: JSONDecoder())
            .map { $0.sorted() }
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
        
        struct Lang: Codable {
            let enUs: EnUs
            
            enum CodingKeys: String, CodingKey {
                case enUs = "en-us"
            }
            
            struct EnUs: Codable {
                let jsonPath, localeNamesPath, csvPath, initialPath: String
                let shards: Shards
                
                struct Shards: Codable {
                    let defaults: String
                }
            }
        }
        
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
    
    //  MARK: - Endpoint
    private enum Endpoint {
        case jsonPath, localeNamesPath, csvPath, initialPath
    }
    
    
    
    
    
    //  MARK: - old urls for reference
    //  JSON (data, no GeoType)
    private static let urlMobilityJSON = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev51/v2/en-us/applemobilitysources.json")!
    //  JSON locale names (plain string array, no GeoType)
    private static let urlLocaleNamesJSON = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev51/v2/en-us/locale-names.json")!
    
    //  CSV (everything, but date in filename makes uptade tricky)
    private static let urlMobilityCSV = URL(string: "https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev53/v2/en-us/applemobilitysources-2020-05-08.csv")!
}
