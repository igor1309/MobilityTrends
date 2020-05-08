//
//  GeoType.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum GeoType: String, CaseIterable, Codable {
    case country = "country/region"
    case city = "city"
    case subRegion = "sub-region"
}
