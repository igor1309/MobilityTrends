//
//  Region.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 09.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

struct Region: Identifiable, Hashable, Codable {
    var id: String { name }
    let name: String
    let type: GeoType
    let subRegion: String
    let country: String
}
