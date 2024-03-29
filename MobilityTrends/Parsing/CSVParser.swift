//
//  CSVParser.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftPI

enum CSVParser {
    enum ParserError: Error { case general }
    
    static func parseCSVToMobilityData(csv: String) throws -> MobilityData {
        guard !csv.isEmpty else {
            print("empty csv")
            return MobilityData(sources: [], regions: [])
        }
        
        let rows = csv.components(separatedBy: "\n")
        var table = [[String]]()
        
        for row in rows {
            table.append(row.components(separatedBy: ","))
        }
        
        let x = table[0].dropFirst(6)
        
        var sources = [Source]()
        var regions = [Region]()
        
        for i in 1..<table.count-1 {
            let row = table[i]
            
            guard let geoType: GeoType = GeoType(rawValue: row[0]) else {
                print("GeoType parsing error")
                throw ParserError.general
            }
            
            guard let transport: TransportType = TransportType(rawValue: row[2]) else {
                print("TransportType parsing error")
                throw ParserError.general
            }
            
            sources.append(Source(region: row[1],
                                  geoType: geoType,
                                  transportType: transport,
                                  datesStr: Array(x),
                                  series: row.dropFirst(6).map { Double($0) ?? -1 }))
            
            let name = row[1]
            guard !regions.map({ $0.name }).contains(name) else { continue }
            regions.append(Region(name: row[1], type: geoType, subRegion: row[4], country: row[5]))
        }
        
        //        print(sources)
        
        return MobilityData(sources: sources, regions: regions)
    }
    
    static func parseCSVToSources(csv: String) throws -> [Source] {
        guard csv.isNotEmpty else {
            print("empty csv")
            return []
        }
        
        let rows = csv.components(separatedBy: "\n")
        var table = [[String]]()
        
        for row in rows {
            table.append(row.components(separatedBy: ","))
        }
        
        let x = table[0].dropFirst(6)
        
        var sources = [Source]()
        
        for i in 1..<table.count-1 {
            let row = table[i]
            
            guard let geoType: GeoType = GeoType(rawValue: row[0]) else {
                print("GeoType parsing error")
                throw ParserError.general
            }
            
            guard let transport: TransportType = TransportType(rawValue: row[2]) else {
                print("TransportType parsing error")
                throw ParserError.general
            }
            
            sources.append(Source(region: row[1],
                                  geoType: geoType,
                                  transportType: transport,
                                  datesStr: Array(x),
                                  series: row.dropFirst(6).map { Double($0) ?? -1 }))
        }
        
        //        print(sources)
        
        return sources
    }
    
    static func parseCSVToRegions(csv: String) throws -> [Region] {
        guard csv.isNotEmpty else {
            print("empty csv")
            return []
        }
        
        let rows = csv.components(separatedBy: "\n")
        var table = [[String]]()
        
        for row in rows {
            table.append(row.components(separatedBy: ","))
        }
        
        var regions = [Region]()
        
        for i in 1..<table.count-1 {
            let row = table[i]
            
            let name = row[1]
            guard !regions.map({ $0.name }).contains(name) else { continue }
            
            guard let geoType: GeoType = GeoType(rawValue: row[0]) else {
                print("GeoType parsing error")
                throw ParserError.general
            }
            
            regions.append(Region(name: row[1], type: geoType, subRegion: row[4], country: row[5]))
        }
        //        print(regions)
        
        return regions
    }
}
