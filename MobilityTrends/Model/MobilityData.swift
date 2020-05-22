//
//  MobilityData.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 22.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

struct MobilityData: Codable {
    var sources: [Source]
    var regions: [Region]
}

extension MobilityData {
    init() {
        self.init(sources: [], regions: [])
    }
}
