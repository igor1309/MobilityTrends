//
//  Trend.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 10.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

struct Trend {
    
    let xLabelsForSelected: [String]
    let trendsForSelected: [TransportType: [Double]]
    let movingAverageForSelected: [TransportType: [Double]]
    
    let isEmpty: Bool
    let isNotEmpty: Bool
    
    let selectedRegionMinY: Double
    let selectedRegionMaxY: Double
    
    let lastMovingAveragesForSelectedRegion: [Tail]
    let lastMovingAverageAverage: Double
}

extension Trend {
    
    init(sources: [Source], selectedRegion region: String) {
        
        func movingAverageSeries(for original: [Double]) -> [Double] {
            
            guard original.isNotEmpty else { return [] }
            
            var maSeries = [Double]()
            for i in 0..<original.count {
                let slice = original.prefix(i + 1).suffix(7)
                let avg = slice.reduce(0, { $0 + $1 }) / Double(slice.count)
                maSeries.append(avg)
            }
            return maSeries
        }
        
        let allSeriesForSelected = sources.filter { $0.region == region }
        
        if allSeriesForSelected.count > 0 {
            xLabelsForSelected = allSeriesForSelected[0].datesStr
        } else {
            xLabelsForSelected = []
        }
        
        trendsForSelected =
            allSeriesForSelected.reduce(into: [TransportType: [Double]]()) {
                $0[$1.transportType] = $1.series
        }
        movingAverageForSelected = trendsForSelected.mapValues { movingAverageSeries(for: $0) }
        
        isEmpty = sources.isEmpty
        isNotEmpty = !sources.isEmpty
        
        lastMovingAveragesForSelectedRegion = allSeriesForSelected
            .compactMap {
                Tail(type: $0.transportType, last:
                    movingAverageSeries(for: $0.series).last!)
        }
        
        lastMovingAverageAverage = lastMovingAveragesForSelectedRegion
            .map { $0.last }
            .reduce(0, { $0 + $1 }) / Double(lastMovingAveragesForSelectedRegion.count)
        
        //  MARK: - FINISH WITH THIS - IT SHOULD BE SMART!!
        //  - to define Y Ssale
        //  - to use moving average (how?)
        let allSeriesFlat = allSeriesForSelected.flatMap { $0.series }
        selectedRegionMinY = ((allSeriesFlat.min() ?? 1) / 10).rounded(.down) * 10
        selectedRegionMaxY = ((allSeriesFlat.max() ?? 1) / 10).rounded(.up) * 10
    }
}

