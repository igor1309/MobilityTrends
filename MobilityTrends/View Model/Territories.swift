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
    private let regionsFilename = "regions.json"
    
    @Published private(set) var favorites = [String]() {
        didSet {
            saveFavorites()
        }
    }
    
    @Published var query: String = ""
    @Published var selectedGeoType = GeoType.country
    @Published var queryResult = [Region]()
    
    /// source - applemobilitytrends-2020-xx-xx.csv
    private var regions = [Region]() {
        didSet {
            allRegionsUpdated.send()
            saveAllRegions()
        }
    }
    private let allRegionsUpdated = PassthroughSubject<Void, Never>()
    
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
    
    init(api: MobilityTrendsAPI = .shared) {
        self.mobilityTrendsAPI = api
        
        //  load saved data from local JSON
        self.regions = loadAllRegions()
        self.favorites = loadFavorites()
        
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

//  MARK: - Fetch and Subcsriptions
extension Territories {
    
    func fetch(version: Int) {
        switch updateStatus {
        case .updating:
            break
        default:
            updateStatus = .updating
            self.updateRequested.send(version)
        }
    }
    
    private func createUpdateCSVSubscription() {
        updateRequested
            .flatMap { version in self.mobilityTrendsAPI.fetchTerritoriesWithEmpty(version: version) }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] in
                if $0.isEmpty {
                    print("recieved empty territories: empty response or error upstream")
                    self?.updateStatus = .updateFail
                } else {
                    self?.regions = $0
                    self?.updateStatus = .updatedOK
                    if self != nil { print("updated regions from csv") }
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
                array = regions
            case .country:
                array = regions.filter { $0.type == .country }
            case .city:
                array = regions.filter { $0.type == .city }
            case .subRegion:
                array = regions.filter { $0.type == .subRegion }
            case .county:
                array = regions.filter { $0.type == .county }
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
            allRegionsUpdated
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
    }
    
    func delete(region: String) {
        favorites.removeAll { $0 == region }
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
    }
    
    func delete(at offsets: IndexSet) {
        favorites.remove(atOffsets: offsets)
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
            guard self.regions.isNotEmpty else { return }
            saveJSONToDocDir(data: self.regions, filename: self.regionsFilename)
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
