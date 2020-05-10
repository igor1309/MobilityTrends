//
//  Territories.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI
import Combine

final class Territories: ObservableObject {
    private let mobilityTrendsAPI: MobilityTrendsAPI
    
    private let favoritesFilename = "favorites.json"
    private let localesFilename = "locales.json"
    private let regionsFilename = "territories.json"
    
    @Published private(set) var favorites = [String]()
    
    @Published var query: String = ""
    @Published var selectedGeoType = GeoType.country
    @Published var queryResult = [Region]()
    
    /// source - locale-names.json
    @Published var locales = [String]()
    
    /// source - applemobilitytrends-2020-xx-xx.csv
    @Published var allRegions = [Region]() {
        didSet {
            updateRegionLists()
        }
    }
    @Published var countries = [Region]()
    @Published var cities = [Region]()
    @Published var subRegions = [Region]()
    
    var updateRequested = PassthroughSubject<String, Never>()
    
    init(api: MobilityTrendsAPI = .shared) {
        self.mobilityTrendsAPI = api
        
        //  load regions from JSON
        self.locales = loadLocales(localesFilename)
        self.allRegions = loadAllRegions(regionsFilename)
        self.favorites = loadFavorites(favoritesFilename)
        
        //  Update Region Lists (since observer didSet is not called at init)
        self.updateRegionLists()
        
        //  create subscriptions
        self.createUpdateJSONSubscription()
        self.createUpdateCSVSubscription()
        self.createSearchSubscription()
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

//  MARK: - Update stored properties (cheaper than computed properties)
extension Territories {
    private func updateRegionLists() {
        countries =  allRegions.filter { $0.type == .country }
        cities =     allRegions.filter { $0.type == .city }
        subRegions = allRegions.filter { $0.type == .subRegion }
    }
}

//  MARK: - Fetch and Subcsriptions
extension Territories {
    func fetch() {
        updateRequested.send("update")
    }
    
    ///  create update (fetch) subscription | source locale-names.json
    private func createUpdateJSONSubscription() {
        updateRequested
            .setFailureType(to: Error.self)
            .flatMap { _ -> AnyPublisher<[String], Error> in
                self.mobilityTrendsAPI.fetchLocaleNamesJSON()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(_):
                    print("error getting regions from JSON in Bundle")
                case .finished:
                    print("getting regions from JSON in Bundle ok")
                }
        }) { [weak self] value in
            guard value.isNotEmpty else {
                print("returned empty trends array, no new data")
                return
            }
            
            print("fetched on-empty data")
            
            self?.locales = value
            
            if self != nil {
                self!.saveLocales()
            }
        }
        .store(in: &cancellables)
    }
    
    private func createUpdateCSVSubscription() {
        updateRequested
            .flatMap { _ -> AnyPublisher<String, Never> in
                self.mobilityTrendsAPI.fetchMobilityCSV()
        }
        .tryMap { try CSVParser.parseCSVToRegions(csv: $0) }
        .catch { _ in Just([]) }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink {
            [weak self] in
            self?.allRegions = $0
            if self != nil {
                print("updated regions from csv")
                self!.saveAllTerritories()
            }
        }
        .store(in: &cancellables)
    }
    
    
    ///  create search query subscription
    private func createSearchSubscription() {
        Publishers.CombineLatest3(
            $query
                .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main),
            $selectedGeoType,
            $allRegions)
            .map { query, type, _ in
                self.queryList(for: query, with: type)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink {
            [weak self] in
            self?.queryResult = $0
        }
        .store(in: &cancellables)
    }
    
    private func queryList(for query: String, with type: GeoType) -> [Region] {
        let array: [Region]
        
        switch type {
        case .all:
            array = locales.map { Region(name: $0, type: .all) }
        case .country:
            array = countries
        case .city:
            array = cities
        case .subRegion:
            array = subRegions
        }
        
        let result = array.filter {
            query.isNotEmpty
                ? $0.name.lowercased().contains(query.lowercased())
                : true
        }
        
        return result
    }
}

//  MARK: - Handling favorites
extension Territories {
    func isFavorite(region: String) -> Bool {
        favorites.contains(region)
    }
    
    func add(region: String) {
        guard !favorites.contains(region) else { return }
        
        favorites.append(region)
        saveFavorites()
    }
    
    func delete(region: String) {
        favorites.removeAll { $0 == region }
        saveFavorites()
    }
    
    func toggleFavorite(region: String) {
        if isFavorite(region: region) {
            delete(region: region)
        } else {
            add(region: region)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        favorites.move(fromOffsets: source, toOffset: destination)
        saveFavorites()
    }
    
    func delete(at offsets: IndexSet) {
        favorites.remove(atOffsets: offsets)
        saveFavorites()
    }
}

//  MARK: - Load and Save
extension Territories {
    private func loadAllRegions(_ filename: String) -> [Region] {
        //  load regions from JSON
        guard let saved: [Region] = loadJSONFromDocDir(filename) else {
            return []
        }
        
        return saved
    }
    
    private func saveAllTerritories() {
        DispatchQueue.global().async {
            guard self.allRegions.isNotEmpty else { return }
            saveJSONToDocDir(data: self.allRegions, filename: self.regionsFilename)
        }
    }
    
    private func loadLocales(_ filename: String) -> [String] {
        //  load regions from JSON
        guard let saved: [String] = loadJSONFromDocDir(filename) else {
            return []
        }
        
        return saved
    }
    
    private func saveLocales() {
        DispatchQueue.global().async {
            guard self.locales.isNotEmpty else { return }
            saveJSONToDocDir(data: self.locales, filename: self.localesFilename)
        }
    }
    
    private func loadFavorites(_ filename: String) -> [String] {
        //  load regions from JSON
        guard let saved: [String] = loadJSONFromDocDir(filename) else {
            return ["Moscow", "Russia", "Rome", "Italy", "France"]
        }
        
        return saved
    }
    
    private func saveFavorites() {
        DispatchQueue.global().async {
            guard self.favorites.isNotEmpty else { return }
            saveJSONToDocDir(data: self.favorites, filename: self.favoritesFilename)
        }
    }
}