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
    private let mobilityTrendsAPI: MobilityTrendsAPI
    private let filename: String = "apple-mobility.json"
    let baseline: Double = 100
    
    @Published private(set) var sources = [Source]()
    
    @Published var selectedRegion = "Moscow"
    @Published var transportType = TransportType.driving
    
    var updateRequested = PassthroughSubject<String, Never>()
    
    init(api: MobilityTrendsAPI = .shared) {
        self.mobilityTrendsAPI = api
        
        //  MARK: load dataSet from JSON
        //        sources = loadSources(filename)
        
        //  MARK: TESTING
        //  get Sources from remote JSON ans save to Document Directory
        //        getSourcesFromRemoteJSONAndSave()
        //          get local JSON
        loadSourcesFromLocalJSON()
        
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
                self.mobilityTrendsAPI.fetchMobilityJSON()
        }
        .map { self.convertMobilityToSources($0) }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(_):
                    print("error converting Mobility from fetched JSON to Sources")
                case .finished:
                    print("converting Mobility from fetched JSON to Sources ok")
                }
        }) { [weak self] value in
            guard value.isNotEmpty else {
                print("returned empty Sources array, no new data")
                return
            }
            
            print("fetched on-empty data")
            
            self?.sources = value
            
            if self != nil {
                self!.saveSources()
            }
        }
        .store(in: &cancellables)
    }
}

//  MARK: - Series and other properties and methods
extension Store {
    var isEmpty: Bool { sources.isEmpty }
    var isNotEmpty: Bool { !sources.isEmpty }
    
    var originalSeries: [Double] {
        series(for: selectedRegion, transportType: transportType)
    }
    
    var movingAverageSeries: [Double] {
        movingAverageSeries(for: selectedRegion, transportType: transportType)
    }
    
    var lastMovingAveragesForSelectedRegion: [Tail] {
        var lastMAs = [Tail]()
        
        for type in TransportType.allCases {
            guard let last = movingAverageSeries(for: selectedRegion, transportType: type).last else { continue }
            lastMAs.append(Tail(type: type, last: last))
        }
        
        return lastMAs.sorted(by: { $0.last > $1.last })
    }
    
    var lastMovingAverageAverage: Double {
        guard lastMovingAveragesForSelectedRegion.isNotEmpty else { return 0 }
        return lastMovingAveragesForSelectedRegion
            .map { $0.last }
            .reduce(0, { $0 + $1 }) / Double(lastMovingAveragesForSelectedRegion.count)
    }
    
    //  MARK: - FINISH WITH THIS - IT SHOULD BE SMART!!
    //  - to define Y Ssale
    //  - to use moving average (how?)
    var selectedRegionMinY: Double {
        let min = sources
            .filter { $0.region == selectedRegion }
            .flatMap { $0.series }
            .min()
        
        return min ?? 1
    }
    var selectedRegionMaxY: Double {
        let max = sources
            .filter { $0.region == selectedRegion }
            .flatMap { $0.series }
            .max()
        
        return max ?? 1
    }
    
    func series(for region: String, transportType: TransportType) -> [Double] {
        guard let trend = sources.first(where: { $0.region == region && $0.transportType == transportType }) else {
            return []
        }
        
        return trend.series
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

//  MARK: - Mobility to Sources Conversion
extension Store {
    private func convertMobilityToSources(_ mobility: Mobility) -> [Source] {
        var sources = [Source]()
        
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
                
                sources.append(
                    Source(region: region,
                          //    MARK: THAT'S NOT CORRECT!!!
                        geoType: .country,
                        transportType: TransportType(rawValue: data.name.rawValue)!,
                        datesStr: data.values.map { $0.date },
                        series:  series)
                )
            }
        }
        return sources
    }
}

//  MARK: - Load and Save
extension Store {
    private func loadSources(_ filename: String) -> [Source] {
        guard let savedDataSet: [Source] = loadJSONFromDocDir(filename) else {
            return []
        }
        return savedDataSet
    }
    
    private func saveSources() {
        guard sources.isNotEmpty else { return }
        
        DispatchQueue.main.async {
            saveJSONToDocDir(data: self.sources, filename: self.filename)
        }
    }
}

//  MARK: - Sources From Local JSON
extension Store {
    
    //  get Sources From Local JSON
    private func loadSourcesFromLocalJSON() {
        Bundle.main.fetch("applemobilitysources.json", type: Mobility.self)
            .map { self.convertMobilityToSources($0) }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(_):
                        print("error converting Mobility from JSON in Bundle to Sources")
                    case .finished:
                        print("converting Mobility from JSON in Bundle to Sources ok")
                    }
            }) { [weak self] value in
                guard value.isNotEmpty else {
                    print("returned empty sources array, no new data")
                    return
                }
                
                print("fetched on-empty data")
                
                self?.sources = value
                
                if self != nil {
                    self!.saveSources()
                }
        }
        .store(in: &cancellables)
    }
}

//  MARK: - TESTING
extension Store {
    
    //  TESTING ONLY
    //  fetch Sources from remote JSON ans save to Document Directory
    private func fetchSourcesFromRemoteJSONAndSave() {
        
        self.mobilityTrendsAPI.fetchMobilityJSON()
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
                saveJSONToDocDir(data: $0, filename: "applemobilitysources.json")
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
                self.mobilityTrendsAPI.fetchMobilityCSV()
        }
        .tryMap { try CSVParser.parseCSVToSources(csv: $0) }
        .catch { _ in Just([]) }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink { [weak self] value in
            guard value.isNotEmpty else {
                print("parser returned empty array, no new data")
                return
            }
            
            print("fetched on-empty data")
            
            self?.sources = value
            
            if self != nil {
                self!.saveSources()
            }
        }
        .store(in: &cancellables)
    }
}
