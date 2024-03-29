//
//  GeoType.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum GeoType: String, CaseIterable, Codable, Hashable {
    case all
    case country = "country/region"
    case city = "city"
    case subRegion = "sub-region"
    case county
    
    var id: String {
        switch self {
        case .country:
            return "country"
        case .subRegion:
            return "sub-reg"
        default:
            return rawValue
        }
    }
}

/// country/region
/// city
/// sub-region
/// county
