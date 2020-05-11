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
    private let regionsFilename = "regions.json"
    
    @Published private(set) var favorites = [String]()
    
    @Published var query: String = ""
    @Published var selectedGeoType = GeoType.country
    @Published var queryResult = [Region]()
    
    /// source - applemobilitytrends-2020-xx-xx.csv
    var allRegions = [Region]() {
        didSet {
            updateRegionLists()
            saveAllRegions()
        }
    }
    @Published var countries = [Region]()
    @Published var cities = [Region]()
    @Published var subRegions = [Region]()
    
    var updateRequested = PassthroughSubject<String, Never>()
    
    init(api: MobilityTrendsAPI = .shared) {
        self.mobilityTrendsAPI = api
        
        //  load saved data from local JSON
        self.allRegions = loadAllRegions()
        self.favorites = loadFavorites()
        
        // Note how we need to manually call our handling
        // method within our initializer, since property
        // observers aren't triggered until after a value
        // has been fully initialized.
        self.updateRegionLists()
        
        //  create subscriptions
        self.createUpdateCSVSubscription()
        self.createSearchSubscription()
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
            if self != nil { print("updated regions from csv") }
        }
        .store(in: &cancellables)
    }
    
    
    ///  create search query subscription
    private func createSearchSubscription() {
        func queryList(for query: String, with type: GeoType) -> [Region] {
            let array: [Region]
            
            switch type {
            case .all:
                array = allRegions
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
        
        Publishers.CombineLatest3(
            $query
                .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
                .removeDuplicates(),
            $selectedGeoType,
            Publishers.CombineLatest3(
                $countries
                    .removeDuplicates(),
                $cities
                    .removeDuplicates(),
                $subRegions
                    .removeDuplicates()
            )
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
    private func loadAllRegions() -> [Region] {
        //  load regions from JSON
        guard let saved: [Region] = loadJSONFromDocDir(regionsFilename) else {
            return []
        }
        
        return saved
    }
    
    private func saveAllRegions() {
        DispatchQueue.global().async {
            guard self.allRegions.isNotEmpty else { return }
            saveJSONToDocDir(data: self.allRegions, filename: self.regionsFilename)
        }
    }
    
    private func loadFavorites() -> [String] {
        //  load regions from JSON
        guard let saved: [String] = loadJSONFromDocDir(favoritesFilename) else {
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
