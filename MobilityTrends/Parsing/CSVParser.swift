//
//  CSVParser.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum CSVParser {
    enum ParserError: Error { case general }
    
    static func parseCSVToTrends(csv: String) throws -> [Trend] {
        guard csv.isNotEmpty else {
            print("empty csv")
            return []
        }

        let rows = csv.components(separatedBy: "\n")
        var table = [[String]]()
        
        for row in rows {
            table.append(row.components(separatedBy: ","))
        }
        
        let x = table[0].dropFirst(4)
        
        var trends = [Trend]()
        
        for i in 1..<table.count-1 {
            let row = table[i]
            
            guard let geoType:GeoType = GeoType(rawValue: row[0]) else { throw ParserError.general }
            
            trends.append(Trend(region: row[1],
                                geoType: geoType,
                                transportType: TransportType(rawValue: row[2])!,
                                datesStr: Array(x),
                                series: row.dropFirst(4).map { Double($0) ?? -1 }))
        }
        print(trends)
        
        return trends
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
            
            guard let geoType:GeoType = GeoType(rawValue: row[0]) else { throw ParserError.general }
            
            regions.append(Region(name: row[1],
                                  type: geoType))
        }
        print(regions)
        
        return regions
    }
    
}
