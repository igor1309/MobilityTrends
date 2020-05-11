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
    
    private let sourcesFilename: String = "sources.json"
    
    let baseline: Double = 100
    
    @Published private(set) var trend = Trend()
    
    private var sources = [Source]() {
        didSet {
            sourcesUpdated.send("updated")
            saveSources()
        }
    }
    private var sourcesUpdated = PassthroughSubject<String, Never>()
    
    @Published var selectedRegion = "Moscow"
    @Published var transportType = TransportType.driving
    
    var updateRequested = PassthroughSubject<String, Never>()
    
    init(api: MobilityTrendsAPI = .shared) {
        self.mobilityTrendsAPI = api
        
        //  create subscriptions
        self.createUpdateTrendSubscriptions()
        self.createCSVSubscription()
        //  not used anymore
        //        createJSONSubscription()
        
        //  load dataSet from JSON
        self.sources = loadSources()
        
        // Note how we need to manually call our handling
        // method within our initializer, since property
        // observers aren't triggered until after a value
        // has been fully initialized.
        self.sourcesUpdated.send("updated")
        
        //  MARK: TESTING/DEBUGGING ONLY
        //  get Sources from remote JSON and save to Document Directory
        //        getSourcesFromRemoteJSONAndSave()
        //          get local JSON
        //        loadSourcesFromBundle()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}

//  MARK: - Fetch and Subcsriptions
extension Store {
    
    func fetch() { updateRequested.send("update") }
    
    //  MARK: subscription to update Trend when user changes selections or sources are updated
    private func createUpdateTrendSubscriptions() {
        
        Publishers.CombineLatest3(
            sourcesUpdated,
            $selectedRegion
                .removeDuplicates(),
            $transportType
        )
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] _ in
                if self != nil {
                    self!.trend = Trend(sources: self!.sources,
                                        selectedRegion: self!.selectedRegion)
                }
        }
        .store(in: &cancellables)
    }
    
    
    //  MARK: subscription to update sources from CSV
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
        .sink { [weak self] sources in
            guard sources.isNotEmpty else {
                print("parser returned empty array, no new data")
                return
            }
            print("fetched on-empty data")
            self?.sources = sources
            if self != nil { print("sources updated") }
        }
        .store(in: &cancellables)
    }
}

//  MARK: - Load and Save
extension Store {
    private func loadSources() -> [Source] {
        guard let savedDataSet: [Source] = loadJSONFromDocDir(sourcesFilename) else {
            return []
        }
        return savedDataSet
    }
    
    private func saveSources() {
        DispatchQueue.global().async {
            guard self.sources.isNotEmpty else { return }
            saveJSONToDocDir(data: self.sources, filename: self.sourcesFilename)
        }
    }
}







//  MARK: - handling JSON data source NOT USED
extension Store {
    //  MARK: sources from JSON
    private func createJSONSubscription() {
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
        }) { [weak self] sources in
            guard sources.isNotEmpty else {
                print("returned empty Sources array, no new data")
                return
            }
            print("fetched on-empty data")
            self?.sources = sources
            if self != nil { print("sources updated") }
        }
        .store(in: &cancellables)
    }
    
    //  MARK: Convert Mobility to Sources
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
                           //   -----------------------------------------------
                        //    MARK: THAT'S NOT CORRECT!!!
                        //  but JSON does not have GeoType info!
                        geoType: .country,
                        //   -----------------------------------------------
                        transportType: TransportType(rawValue: data.name.rawValue)!,
                        datesStr: data.values.map { $0.date },
                        series:  series)
                )
            }
        }
        return sources
    }
    
    //  MARK: load Sources From JSON in Bundle
    private func loadSourcesFromBundle() {
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
            }) { [weak self] sources in
                guard sources.isNotEmpty else {
                    print("returned empty sources array, no new data")
                    return
                }
                print("fetched on-empty data")
                self?.sources = sources
                if self != nil { print("sources updated") }
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

