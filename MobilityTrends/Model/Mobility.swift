//
//  Mobility.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 09.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.

// MARK: - Mobility
struct Mobility: Codable {
    let data: [String: [Datum]]
    let meta: Meta
}

// MARK: - Datum
struct Datum: Codable {
    let name, title: Name
    let values: [Value]
}

enum Name: String, Codable {
    case driving = "driving"
    case transit = "transit"
    case walking = "walking"
}

// MARK: - Value
struct Value: Codable {
    let date, value: String
}

// MARK: - Meta
struct Meta: Codable {
    let earliestDate, latestDate: String
    let initialRegions: [String]
    let alts: [String: String]
    let rowMaxP80, absoluteMax, absoluteMin: Double
}
