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
    
    let filename: String
    
    var updateRequested = PassthroughSubject<String, Never>()
    
    @Published private(set) var trends = [Trend]()
    
    @Published var selectedRegion = "Moscow"
    @Published var transportation = TransportType.driving
    
    @Published var query: String = ""
    @Published var selectedGeoType = GeoType.country
    @Published var queryList = [String]()
    
    var allRegions = [String]()
    var countries = [String]()
    var cities = [String]()
    var subRegions = [String]()
    
    var originalSeries: [Double] {
        series(for: selectedRegion, transportType: transportation)
    }
    var movingAverageSeries: [Double] {
        movingAverageSeries(for: selectedRegion, transportType: transportation)
    }
    
    init(_ filename: String = "apple-mobility.json") {
        
        self.filename = filename
        
        //  MARK: load dataSet from JSON
        trends = loadTrends(filename)
        
        //  create properties
        createProperties()
        
        //  create subscriptions
        createSubscriptions()
    }
    
    private func createSubscriptions() {
        //  create update (fetch) subscription
        updateRequested
            .flatMap { _ in
                MobilityTrendsAPI.getMobilityData(url: MobilityTrendsAPI.url)
        }
        .map { CSVParser.parseCSVToTrends(csv: $0) }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink { [weak self] value in
            guard value.isNotEmpty else { return }
            
            self?.trends = value
            self?.createProperties()
            
            if self != nil {
                self!.saveTrends()
            }
        }
        .store(in: &cancellables)
        
        //  create search query subscription
        Publishers.CombineLatest($query, $selectedGeoType)
            .map { query, type in
                query
        }
        .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .map { self.queryResult(query: $0) }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink {
            [weak self] in
            self?.queryList = $0
        }
        .store(in: &cancellables)
    }
    
    func queryResult(query: String) -> [String] {
        let array: [String]
        
        switch selectedGeoType {
        case .country:
            array = countries
        case .city:
            array = cities
        case .subRegion:
            array = subRegions
        }
        
        return array.filter { $0.contains(query) }
    }
    
    private func createProperties() {
        allRegions = trends.map { $0.region }.removingDuplicates()
        countries = trends.filter { $0.geoType == .country }.map { $0.region }.removingDuplicates()
        cities = trends.filter { $0.geoType == .city }.map { $0.region }.removingDuplicates()
        subRegions = trends.filter { $0.geoType == .subRegion }.map { $0.region }.removingDuplicates()
    }
    
    func fetch() {
        updateRequested.send("update")
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
    
    private func series(for region: String, transportType: TransportType) -> [Double] {
        guard let slice = trends.first(where: { $0.region == region && $0.transportType == transportType }) else {
            return []
        }
        
        return slice.series
    }
    
    private func movingAverageSeries(for region: String, transportType: TransportType) -> [Double] {
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
