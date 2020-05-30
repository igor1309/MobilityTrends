//
//  CurrentMobility.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 30.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CurrentMobility {
    private var mobilityIndexData: [(region: String, geoType: GeoType, transport: TransportType, value: CGFloat)]
    
    struct MobilityIndex: Identifiable {
        var id = UUID()
        let region: String
        let value: CGFloat
        let normalized: CGFloat
    }
    
    init(sources: [Source]) {
        mobilityIndexData = sources
            .map {
                source in
                let region = source.region
                let geoType = source.geoType
                let transport = source.transportType
                
                let startWeekAverage = source.series.prefix(7).reduce(0, +) / 7
                let lastWeekAverage = source.series.suffix(7).reduce(0, +) / 7
                let mobilityIndex = lastWeekAverage / startWeekAverage
                
                return (region: region, geoType: geoType, transport: transport, value: CGFloat(mobilityIndex))
        }
    }
    
    
    func mobilityIndexMax(geoType: GeoType, transport: TransportType) -> CGFloat {
        
        let max: CGFloat = mobilityIndexData
            .filter { $0.geoType == geoType && $0.transport == transport }
            .map { $0.value }
            .max() ?? 1
        
        return max == 0 ? 1 : max
    }
    
    func mobilityIndex(geoType: GeoType, transport: TransportType) -> [MobilityIndex] {
        
        let maxValue: CGFloat = mobilityIndexMax(geoType: geoType, transport: transport)
        
        return mobilityIndexData
            .filter { $0.geoType == geoType && $0.transport == transport }
            .map { MobilityIndex(region: $0.region, value: $0.value, normalized: $0.value / maxValue) }
    }
}
