//
//  FavoriteRegions.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

final class FavoriteRegions: ObservableObject {
    let filename: String
    
    @Published private(set) var regions = [String]()
    
    func isFavorite(region: String) -> Bool {
        regions.contains(region)
    }
    
    init(_ filename: String = "favorite-regions.json") {
        self.filename = filename
        
        //  load regions from JSON
        self.regions = load(filename)
    }
    
    func add(region: String) {
        guard !regions.contains(region) else { return }
        
        regions.append(region)
        save()
    }
    
    func delete(region: String) {
        regions.removeAll { $0 == region }
        save()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        regions.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    func delete(at offsets: IndexSet) {
        regions.remove(atOffsets: offsets)
        save()
    }
    
    private func load(_ filename: String) -> [String] {
        //  load regions from JSON
        guard let saved: [String] = loadJSONFromDocDir(filename) else {
            return ["Moscow", "Russia"]
        }
        
        return saved
    }
    
    private func save() {
        guard regions.isNotEmpty else { return }
        
        DispatchQueue.main.async {
            saveJSONToDocDir(data: self.regions, filename: self.filename)
        }
    }
    
}
