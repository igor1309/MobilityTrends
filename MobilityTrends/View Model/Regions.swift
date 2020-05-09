//
//  Regions.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI
import Combine

struct Region: Identifiable, Codable {
    var id: String { name }
    var name: String
    var type: GeoType
}

final class Regions: ObservableObject {
    private let localesFilename = "locales.json"
    private let regionsFilename = "regions.json"
    private let favoritesFilename = "favorite-regions.json"
    
    var updateRequested = PassthroughSubject<String, Never>()
    
    @Published private(set) var favorites = [String]()
    
    @Published var query: String = ""
    @Published var selectedGeoType = GeoType.country
    @Published var queryResult = [String]()
    
    /// source - locale-names.json
    @Published var locales = [String]()
    
    /// source - applemobilitytrends-2020-xx-xx.csv
    @Published var allRegions = [Region]()
    @Published var countries = [String]()
    @Published var cities = [String]()
    @Published var subRegions = [String]()
    
    init() {
        
        //  load regions from JSON
        self.locales = loadLocales(localesFilename)
        self.allRegions = loadAllRegions(regionsFilename)
        self.favorites = loadFavorites(favoritesFilename)
        
        //  create properties
        createProperties()
        
        //  create subscriptions
        createUpdateJSONSubscription()
        createUpdateCSVSubscription()
        createSearchSubscription()
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
extension Regions {
    func fetch() {
        updateRequested.send("update")
    }
    
    ///  create update (fetch) subscription
    private func createUpdateJSONSubscription() {
        updateRequested
            .setFailureType(to: Error.self)
            .flatMap { _ -> AnyPublisher<[String], Error> in
                MobilityTrendsAPI.fetchMobilityLocalesJSON()
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
                self!.saveRegions()
            }
        }
        .store(in: &cancellables)
    }
    
    private func createUpdateCSVSubscription() {
        updateRequested
            .flatMap { _ -> AnyPublisher<String, Never> in
                MobilityTrendsAPI.fetchMobilityDataCSV()
        }
        .tryMap { try CSVParser.parseCSVToRegions(csv: $0) }
        .catch { _ in Just([]) }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink {
            [weak self] in
            self?.allRegions = $0
        }
        .store(in: &cancellables)
    }

    
    ///  create search query subscription
    private func createSearchSubscription() {
        Publishers.CombineLatest($query, $selectedGeoType)
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .map { query, type in
                self.queryList(query: query, type: type)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink {
            [weak self] in
            self?.queryResult = $0
        }
        .store(in: &cancellables)
    }
    
    private func queryList(query: String, type: GeoType) -> [String] {
        let array: [String]
        
        switch type {
        case .country:
            array = countries
        case .city:
            array = cities
        case .subRegion:
            array = subRegions
        }
        
        return array.filter {
            query.isNotEmpty
                ? $0.lowercased().contains(query.lowercased())
                : true
        }
    }
    
    private func createProperties() {
        //  MARK: - нужен ли .removingDuplicates() ?????
        
        countries = allRegions
            .filter { $0.type == .country }
            .map { $0.name }
            .removingDuplicates()
        
        cities = allRegions
            .filter { $0.type == .city }
            .map { $0.name }
            .removingDuplicates()
        
        subRegions = allRegions
            .filter { $0.type == .subRegion }
            .map { $0.name }
            .removingDuplicates()
    }
}

//  MARK: - Handling favorites
extension Regions {
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
extension Regions {
    private func loadAllRegions(_ filename: String) -> [Region] {
        //  load regions from JSON
        guard let saved: [Region] = loadJSONFromDocDir(filename) else {
            return []
        }
        
        return saved
    }
    
    private func saveRegions() {
        guard allRegions.isNotEmpty else { return }
        
        DispatchQueue.main.async {
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
    
    private func saveLocaless() {
        guard locales.isNotEmpty else { return }
        
        DispatchQueue.main.async {
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
        guard favorites.isNotEmpty else { return }
        
        DispatchQueue.main.async {
            saveJSONToDocDir(data: self.favorites, filename: self.favoritesFilename)
        }
    }
}
