//
//  Source.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 06.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

struct Source: Identifiable, Codable, Hashable {
    let id = UUID()
    let region: String
    let geoType: GeoType
    let transportType: TransportType
    //  MARK: for simplicity at first dates as strings
    let datesStr: [String]
    let series: [Double]
}
