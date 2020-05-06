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
    
    var allRegions = [String]()
    var countries = [String]()
    var cities = [String]()
    var subRegions = [String]()
    
    func series(for region: String, transportationType: TransportationType) -> [Double] {
        guard let slice = trends.first(where: { $0.region == region && $0.transportationType == transportationType }) else {
            return []
        }
        
        return slice.series
    }
    
    init(_ filename: String = "apple-mobility.json") {
        
        self.filename = filename

        //  MARK: load dataSet from JSON
        //  ...
        trends = loadTrends(filename)
        
        //  create subscription
        createProperties()
        
        //  create subscription
        updateRequested
            .flatMap { _ in
                //  MARK: SUBSTITUTE THE PUBLISHER!
                Just([Trend]())
        }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] value in
            self.trends = value
            self.createProperties()
        }
        .store(in: &cancellables)
    }
    
    private func createProperties() {
        allRegions = trends.map { $0.region }
        countries = trends.filter { $0.geoType == .country }.map { $0.region }
        cities = trends.filter { $0.geoType == .city }.map { $0.region }
        subRegions = trends.filter { $0.geoType == .subRegion }.map { $0.region }
    }
    
    func fetch() {
        updateRequested.send("update")
        
        //  MARK: save
        //  ...
        saveJSONToDocDir(data: trends, filename: filename)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
    
    func loadTrends(_ filename: String) -> [Trend] {
        guard let savedDataSet: [Trend] = loadJSONFromDocDir(filename) else {
            return []
        }
        return savedDataSet
    }
}
