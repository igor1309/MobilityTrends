//
//  UpdateStatus.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 22.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

enum UpdateStatus {
    case ready, updating, updatedOK, updateFail
    
    var isUpdating: Bool {
        self == .updating
    }
    var color: Color {
        switch self {
        case .ready:
            return .blue
        case .updating:
            return .secondary
        case .updatedOK:
            return .green
        case .updateFail:
            return .red
        }
    }
    var icon: String {
        switch self {
        case .ready:
            return "arrow.2.circlepath"
        case .updating:
            return "arrow.2.circlepath"
        case .updatedOK:
            return "checkmark.seal.fill"
        case .updateFail:
            return "xmark.seal.fill"
        }
    }
}
