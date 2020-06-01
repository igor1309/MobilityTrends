//
//  MobilityData.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 22.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import CollectionLibrary
import SwiftPI

struct MobilityData: Codable {
    var sources: [Source]
    var regions: [Region]
    
    func collection(for favorites: [String]) -> [CollectionRow] {
        
        //  MARK: НУЖНО ЛИ СНАЧАЛА ФИЛЬРОВАТЬ ПО ФАВОРИТАМ??
        //        let favotiteSources = favorites.flatMap { region in
        //            sources.filter { $0.region == region }
        //        }
        
        return favorites.map { region in
            
            let elements: [CollectionElement] = sources//favotiteSources
                .filter { $0.region == region }
                .sorted(by: { $0.transportType.rawValue < $1.transportType.rawValue })
                .map { source in
                    
                    //  MARK: -ДУБЛИКАТ РАСЧЕТА ИНДЕКСА mobilityIndex!!
                    //  как и в struct struct CurrentMobility init(…)
                    let startWeekAverage = source.series.prefix(7).reduce(0, +) / 7
                    let lastWeekAverage = source.series.suffix(7).reduce(0, +) / 7
                    let mobilityIndex = lastWeekAverage / startWeekAverage
                    
                    return CollectionElement(header: mobilityIndex.formattedGroupedWithDecimals,
                                             subheader: source.transportType.rawValue,
                                             series: source.series.map { CGFloat($0) }
                    )
            }
            //            .sorted(by: { $0.subheader < $1.subheader })
            
            return CollectionRow(title: region,
                                 subtitle: "???",
                                 elements: elements
            )
        }
    }
}

extension MobilityData {
    init() {
        self.init(sources: [], regions: [])
    }
}
