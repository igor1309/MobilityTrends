//
//  Source.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 06.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

struct Source: Identifiable, Codable {
    let id = UUID()
    var region: String
    var geoType: GeoType
    var transportType: TransportType
    //  MARK: for simplicity at first dates as strings
    var datesStr: [String]
    var series: [Double]
}
