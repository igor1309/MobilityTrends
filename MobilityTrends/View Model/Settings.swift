//
//  Settings.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 21.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import SwiftPI

final class Settings: ObservableObject {
    private let mobilityTrendsAPI: MobilityTrendsAPI
    
    @Published var sortByName: Bool = UserDefaults.standard.bool(forKey: "sortByName") {
        didSet {
            UserDefaults.standard.set(sortByName, forKey: "sortByName")
        }
    }
    
    @Published private(set) var favorites = [String]() {
        didSet {
            saveFavorites()
        }
    }
    private let favoritesFilename = "favorites.json"
    
    @Published var selectedTab: Int = UserDefaults.standard.integer(forKey: "selectedTab") {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: "selectedTab")
        }
    }
    
    @Published var version: Int = UserDefaults.standard.integer(forKey: "AppleMobilityVersion") {
        didSet {
            UserDefaults.standard.set(version, forKey: "AppleMobilityVersion")
        }
    }
    
    @Published var pingResult: String = ""
    
    private var pingRequested = PassthroughSubject<Int, Never>()
    
    init(api: MobilityTrendsAPI = .shared) {
        self.mobilityTrendsAPI = api
        
        //  create subscriptions
        self.createPingSubscription()
        
        //  load saved data from local JSON
        self.favorites = loadFavorites()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}

extension Settings {
    
    func ping(version: Int) {
        pingRequested.send(version)
    }
    
    func createPingSubscription() {
        pingRequested
            .flatMap { self.mobilityTrendsAPI.ping(version: $0) }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.pingResult = $0
        }
        .store(in: &cancellables)
    }
    
    var pingResultColor: Color {
        if pingResult.lowercased().contains("error") {
            return .systemRed
        } else {
            return .systemGreen
        }
    }
}

//  MARK: - Handling favorites
extension Settings {
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
extension Settings {
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
