//
//  Trend.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 06.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

enum GeoType: String, CaseIterable, Codable {
    case country = "country/region"
    case city = "city"
    case subRegion = "sub-region"
}


enum TransportType: String, CaseIterable, Codable {
    case driving, walking, transit
}


struct Trend: Identifiable, Codable {
    let id = UUID()
    var region: String
    var geoType: GeoType
    var transportType: TransportType
    //  MARK: for simplicity at first dates as strings
    var dates: [String]
    var series: [Double]
}
