//
//  Store.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 06.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftPI
import Combine
import CollectionLibrary

final class Store: ObservableObject {
    let baseline: Double = 100
    
    @Published private(set) var trend = Trend()
    @Published var selectedRegion = "Moscow"
    @Published var transportType = TransportType.driving
    
    @Published var query: String = ""
    @Published var selectedGeoType = GeoType.country
    @Published var queryResult = [Region]()
    
    var currentMobility = CurrentMobility(sources: [])
    
    private var version: Int = UserDefaults.standard.integer(forKey: "AppleMobilityVersion") {
        didSet {
            UserDefaults.standard.set(version, forKey: "AppleMobilityVersion")
        }
    }
    
    @Published private var mobilityData = MobilityData() {
        didSet {
            saveMobilityData()
        }
    }
    
    //  MARK: - слишком затратное обновление!!
    //  TODO: - сделать хранимой переменной, обновляемой по издателю
    func collection(for favorites: [String]) -> [CollectionRow] {
        mobilityData.collection(for: favorites)
    }
    
    @Published private(set) var updateStatus: UpdateStatus = .ready {
        didSet {
            switch updateStatus {
            case .updatedOK, .updateFail:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.updateStatus = .ready
                }
            default:
                break
            }
        }
    }
    private let updateRequested = PassthroughSubject<Int, Never>()
    
    private let mobilityTrendsAPI: MobilityTrendsAPI
    
    private let mobilityDataFilename: String = "sources.json"
    private let regionsFilename = "regions.json"
    
    init(api: MobilityTrendsAPI = .shared) {
        self.mobilityTrendsAPI = api
        
        if version == 0 { version = 3 }
        
        //  create subscriptions
        self.createCSVSubscription()
        self.createUpdateTrendSubscriptions()
        self.createUpdateCurrentMobilitySubscriptions()
        self.createSearchSubscription()
        
        //  load saved data from local JSON
        self.mobilityData = loadMobilityData()
        
        // Note how we need to manually call our handling
        // method within our initializer, since property
        // observers aren't triggered until after a value
        // has been fully initialized.
        //        self.mobilityDataUpdated.send(version)
        
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
    
    func fetch(version: Int) {
        switch updateStatus {
        case .updating:
            break
        default:
            updateStatus = .updating
            self.version = version
            updateRequested.send(version)
        }
    }
    
    //  MARK: subscription to update Trend when user changes selections or sources are updated
    private func createUpdateTrendSubscriptions() {
        
        Publishers.CombineLatest(
            $mobilityData,
            $selectedRegion
                .removeDuplicates()
        )
            .map { (mobilityData, region) in
                Trend(sources: mobilityData.sources, selectedRegion: region)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            print("completion recieved: \(completion)")
        }) {
            [weak self] in
            self?.trend = $0
        }
        .store(in: &cancellables)
    }
    
    
    //  MARK: subscription to update CurrentMobility when user changes selections or sources are updated
    private func createUpdateCurrentMobilitySubscriptions() {
        Publishers.CombineLatest3(
            $mobilityData,
            $selectedGeoType,
            $transportType
        )
            .map { (mobilityData, geoType, transport) in
                CurrentMobility(sources: mobilityData.sources)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink {
            [weak self] in
            self?.currentMobility = $0
        }
        .store(in: &cancellables)
    }
    
    
    //  MARK: subscription to update sources from CSV
    private func createCSVSubscription() {
        
        //  create update (fetch) subscription for MobilityData
        updateRequested
            .flatMap { _ in
                self.mobilityTrendsAPI.fetchMobilityDataWithEmpty(version: self.version)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink { [weak self] mobilityData in
            if mobilityData.sources.isEmpty {
                print("recieved Mobility Data: empty response, error upstream, or parse error")
                self?.updateStatus = .updateFail
            } else {
                self?.mobilityData = mobilityData
                self?.updateStatus = .updatedOK
                if self != nil { print("updated Mobility Data from csv") }
            }
        }
        .store(in: &cancellables)
    }
    
    ///  create search query subscription
    private func createSearchSubscription() {
        func queryList(for query: String, with type: GeoType) -> [Region] {
            let array: [Region]
            
            switch type {
            case .all:
                array = mobilityData.regions
            case .country:
                array = mobilityData.regions.filter { $0.type == .country }
            case .city:
                array = mobilityData.regions.filter { $0.type == .city }
            case .subRegion:
                array = mobilityData.regions.filter { $0.type == .subRegion }
            case .county:
                array = mobilityData.regions.filter { $0.type == .county }
            }
            
            let result = array.filter {
                query.isNotEmpty
                    ? $0.name.lowercased().contains(query.lowercased())
                    : true
            }
            
            return result
        }
        
        Publishers.CombineLatest3(
            $query
                .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
                .removeDuplicates(),
            $selectedGeoType,
            $mobilityData
        )
            .map { query, type, _ in
                queryList(for: query, with: type)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink {
            [weak self] in
            self?.queryResult = $0
        }
        .store(in: &cancellables)
    }
}

//  MARK: - Load and Save
extension Store {
    private func loadMobilityData() -> MobilityData {
        guard let saved: MobilityData = loadJSONFromDocDir(mobilityDataFilename) else {
            return MobilityData()
        }
        return saved
    }
    
    private func saveMobilityData() {
        DispatchQueue.global().async {
            guard self.mobilityData.sources.isNotEmpty else { return }
            saveJSONToDocDir(data: self.mobilityData, filename: self.mobilityDataFilename)
        }
    }
}



//  MARK: -
//  MARK: - handling JSON data source NOT USED (LESS DATA THAN IN CSV)
extension Store {
    
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
}




//  MARK: -
//  MARK: - TESTING
extension Store {
    
    //  TESTING ONLY
    //  fetch Sources from remote JSON ans save to Document Directory
    private func fetchSourcesFromRemoteJSONAndSave() {
        
        self.mobilityTrendsAPI.fetchMobilityJSON(version: self.version)
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

