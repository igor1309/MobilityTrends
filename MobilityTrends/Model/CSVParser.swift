//
//  CSVParser.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum CSVParser {
    
    static func parseCSVToTrends(csv: String) -> [Trend] {
        guard csv.isNotEmpty else { return [] }
        
        let rows = csv.components(separatedBy: "\n")
        var table = [[String]]()
        
        for row in rows {
            table.append(row.components(separatedBy: ","))
        }
        
        let x = table[0].dropFirst(4)
        
        var trends = [Trend]()
        
        for i in 1..<table.count-1 {
            let row = table[i]
            
            trends.append(Trend(region: row[1],
                                geoType: GeoType(rawValue: row[0])!,
                                transportType: TransportType(rawValue: row[2])!,
                                dates: Array(x),
                                series: row.dropFirst(4).map { Double($0) ?? -1 }))
        }
        
        return trends
    }
    
}
