//
//  Store.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 06.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import SwiftPI
import Combine

final class Store: ObservableObject {
    private let filename: String = "apple-mobility.json"
    let baseline: Double = 100
    
    var updateRequested = PassthroughSubject<String, Never>()
    
    private var trends = [Trend]()
    
    @Published var selectedRegion = "Moscow"
    @Published var transportation = TransportType.driving
    
    init() {
        //  MARK: load dataSet from JSON
        //        trends = loadTrends(filename)
        
        //  MARK: TESTING
        //  get Trends from remote JSON ans save to Document Directory
        //        getTrendsFromRemoteJSONAndSave()
        //          get local JSON
        loadTrendsFromLocalJSON()
        
        //  create subscriptions
        createUpdateSubscription()
        //  not used anymore
        //        createCSVSubscription()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}

//  MARK: - Fetch ans Subcsriptions
extension Store {
    func fetch() {
        updateRequested.send("update")
    }
    
    ///  create update (fetch) subscription
    private func createUpdateSubscription() {
        updateRequested
            .setFailureType(to: Error.self)
            .flatMap { _ -> AnyPublisher<Mobility, Error> in
                MobilityTrendsAPI.fetchMobilityJSON()
        }
        .map { self.convertMobilityToTrends($0) }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(_):
                    print("error converting Mobility from fetched JSON to Trends")
                case .finished:
                    print("converting Mobility from fetched JSON to Trends ok")
                }
        }) { [weak self] value in
            guard value.isNotEmpty else {
                print("returned empty trends array, no new data")
                return
            }
            
            print("fetched on-empty data")
            
            self?.trends = value
            
            if self != nil {
                self!.saveTrends()
            }
        }
        .store(in: &cancellables)
    }
}

//  MARK: - Series and other properties and methods
extension Store {
    var isEmpty: Bool { trends.isEmpty }
    var isNotEmpty: Bool { !trends.isEmpty }
    
    var originalSeries: [Double] {
        series(for: selectedRegion, transportType: transportation)
    }
    
    var movingAverageSeries: [Double] {
        movingAverageSeries(for: selectedRegion, transportType: transportation)
    }
    
    var lastMovingAverageForSelectedRegion: [Tail] {
        var lastMAs = [Tail]()
        
        for type in TransportType.allCases {
            guard let last = movingAverageSeries(for: selectedRegion, transportType: type).last else { continue }
            lastMAs.append(Tail(type: type, last: last))
        }
        
        return lastMAs.sorted(by: { $0.last > $1.last })
    }
    
    var lastMovingAverageAverage: Double {
        guard lastMovingAverageForSelectedRegion.isNotEmpty else { return 0 }
        return lastMovingAverageForSelectedRegion
            .map { $0.last }
            .reduce(0, { $0 + $1 }) / Double(lastMovingAverageForSelectedRegion.count)
    }
    
    //  MARK: - FINISH WITH THIS - IT SHOULD BE SMART!!
    //  - to define Y Ssale
    //  - to use moving average (how?)
    var selectedRegionMinY: Double {
        let min = trends
            .filter { $0.region == selectedRegion }
            .flatMap { $0.series }
            .min()
        
        return min ?? 1
    }
    var selectedRegionMaxY: Double {
        let max = trends
            .filter { $0.region == selectedRegion }
            .flatMap { $0.series }
            .max()
        
        return max ?? 1
    }
    
    func series(for region: String, transportType: TransportType) -> [Double] {
        guard let slice = trends.first(where: { $0.region == region && $0.transportType == transportType }) else {
            return []
        }
        
        return slice.series
    }
    
    func movingAverageSeries(for region: String, transportType: TransportType) -> [Double] {
        let original = series(for: region, transportType: transportType)
        
        guard original.isNotEmpty else { return [] }
        
        var maSeries = [Double]()
        
        for i in 0..<original.count {
            let slice = original.prefix(i + 1).suffix(7)
            let avg = slice.reduce(0, { $0 + $1 }) / Double(slice.count)
            maSeries.append(avg)
        }
        
        return maSeries
    }
}

//  MARK: - Mobility to Trends Conversion
extension Store {
    private func convertMobilityToTrends(_ mobility: Mobility) -> [Trend] {
        var trends = [Trend]()
        
        for (region, dataArray) in mobility.data {
            
            let isTheSame = dataArray
                .reduce(true, { $0 && ($1.name == $1.title) })
            if !isTheSame {
                print("name, title: Name are different? - \(!isTheSame)")
            }
            
            for data in dataArray {
                
                let series = data.values.map { Double($0.value) ?? -1 }
                let hasConversionErrors = series.filter { $0 < 0 }.count != 0
                if hasConversionErrors {
                    print("String to Double conversion has errors")
                }
                
                trends.append(
                    Trend(region: region,
                          //    MARK: THAT'S NOT CORRECT!!!
                        geoType: .country,
                        transportType: TransportType(rawValue: data.name.rawValue)!,
                        datesStr: data.values.map { $0.date },
                        series:  series)
                )
            }
        }
        return trends
    }
}

//  MARK: - Load and Save
extension Store {
    private func loadTrends(_ filename: String) -> [Trend] {
        guard let savedDataSet: [Trend] = loadJSONFromDocDir(filename) else {
            return []
        }
        return savedDataSet
    }
    
    private func saveTrends() {
        guard trends.isNotEmpty else { return }
        
        DispatchQueue.main.async {
            saveJSONToDocDir(data: self.trends, filename: self.filename)
        }
    }
}

//  MARK: - Trends From Local JSON
extension Store {
    
    //  get Trends From Local JSON
    private func loadTrendsFromLocalJSON() {
        Bundle.main.fetch("applemobilitytrends.json", type: Mobility.self)
            .map { self.convertMobilityToTrends($0) }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(_):
                        print("error converting Mobility from JSON in Bundle to Trends")
                    case .finished:
                        print("converting Mobility from JSON in Bundle to Trends ok")
                    }
            }) { [weak self] value in
                guard value.isNotEmpty else {
                    print("returned empty trends array, no new data")
                    return
                }
                
                print("fetched on-empty data")
                
                self?.trends = value
                
                if self != nil {
                    self!.saveTrends()
                }
        }
        .store(in: &cancellables)
    }
}

//  MARK: - TESTING
extension Store {
    
    //  TESTING ONLY
    //  fetch Trends from remote JSON ans save to Document Directory
    private func fetchTrendsFromRemoteJSONAndSave() {
        
        MobilityTrendsAPI.fetchMobilityJSON()
            //        URLSession.shared.fetchData(url: url)
            //            .decode(type: Mobility.self, decoder: JSONDecoder())
            //            .subscribe(on: DispatchQueue.global())
            //  this functiona just saves JSON
            //  there is no UI update so no need in DispatchQueue.main
            // .receive(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global())
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("error getting Mobility from remote JSON \(error)")
                    case .finished:
                        print("read Mobility from remote JSON ok")
                    }
            }) {
                saveJSONToDocDir(data: $0, filename: "applemobilitytrends.json")
        }
        .store(in: &cancellables)
    }
}

//  MARK: - OLD (CSV, not used anymore)
extension Store {
    //  not used anymore
    private func createCSVSubscription() {
        //  create update (fetch) subscription
        updateRequested
            .flatMap { _ in
                MobilityTrendsAPI.fetchMobilityCSV()
        }
        .tryMap { try CSVParser.parseCSVToTrends(csv: $0) }
        .catch { _ in Just([]) }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink { [weak self] value in
            guard value.isNotEmpty else {
                print("parser returned empty array, no new data")
                return
            }
            
            print("fetched on-empty data")
            
            self?.trends = value
            
            if self != nil {
                self!.saveTrends()
            }
        }
        .store(in: &cancellables)
    }
}
