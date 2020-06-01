//
//  TransportType.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

enum TransportType: String, CaseIterable, Codable, Hashable {
    case driving, walking, transit
    
    var color: Color {
        switch self {
        case .driving:
            return .systemTeal
        case .walking:
            return .systemYellow
        case.transit:
            return .purple
        }
    }
}
