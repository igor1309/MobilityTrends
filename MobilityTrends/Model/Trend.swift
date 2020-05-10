//
//  Trend.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 10.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

struct Trend {
    var sources: [Source]
}

//  MARK: - Series and other properties and methods
extension Trend {
    var isEmpty: Bool { sources.isEmpty }
    var isNotEmpty: Bool { !sources.isEmpty }
    
    func lastMovingAveragesForSelectedRegion(for selectedRegion: String) -> [Tail] {
        var lastMAs = [Tail]()
        
        for type in TransportType.allCases {
            guard let last = movingAverageSeries(for: selectedRegion, with: type).last else { continue }
            lastMAs.append(Tail(type: type, last: last))
        }
        
        return lastMAs.sorted(by: { $0.last > $1.last })
    }
    
    func lastMovingAverageAverage(for selectedRegion: String) -> Double {
        guard lastMovingAveragesForSelectedRegion(for: selectedRegion).isNotEmpty else {
            return 0
        }
        return lastMovingAveragesForSelectedRegion(for: selectedRegion)
            .map { $0.last }
            .reduce(0, { $0 + $1 }) / Double(lastMovingAveragesForSelectedRegion(for: selectedRegion).count)
    }
    
    //  MARK: - FINISH WITH THIS - IT SHOULD BE SMART!!
    //  - to define Y Ssale
    //  - to use moving average (how?)
    func selectedRegionMinY(for selectedRegion: String) -> Double {
        let min = sources
            .filter { $0.region == selectedRegion }
            .flatMap { $0.series }
            .min()
        
        return ((min ?? 1) / 10).rounded(.down) * 10
    }
    
    func selectedRegionMaxY(for selectedRegion: String) -> Double {
        let max = sources
            .filter { $0.region == selectedRegion }
            .flatMap { $0.series }
            .max()
        
        return ((max ?? 1) / 10).rounded(.up) * 10
    }
    
    func series(for region: String, with transportType: TransportType) -> [Double] {
        guard let trend = sources.first(where: { $0.region == region && $0.transportType == transportType }) else {
            return []
        }
        
        return trend.series
    }
    
    func movingAverageSeries(for region: String, with type: TransportType) -> [Double] {
        let original = series(for: region, with: type)
        
        guard original.isNotEmpty else { return [] }
        
        var maSeries = [Double]()
        
        for i in 0..<original.count {
            let slice = original.prefix(i + 1).suffix(7)
            let avg = slice.reduce(0, { $0 + $1 }) / Double(slice.count)
            maSeries.append(avg)
        }
        
        return maSeries
    }
}

