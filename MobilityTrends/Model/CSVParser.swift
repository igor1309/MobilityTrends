//
//  CSVParser.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum CSVParser {
    
    static func parseCSVToTrends(csv: String) -> [Trend] {
        print(csv)
        
        guard csv.isNotEmpty else {
            print("empty csv")
            return []
        }
        
        //  MARK: - КАК ОТЛОВИТЬ ОШИБКУ КОГДА ВМЕСТО CSV ПОЛУЧАЕТСЯ HTML ФАЙЛ / response ???
        guard csv.contains("www.w3.org") else {
            print("string to parse is not csv")
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
            
            if GeoType(rawValue: row[0]) != nil {
                trends.append(Trend(region: row[1],
                                    geoType: GeoType(rawValue: row[0])!,
                                    transportType: TransportType(rawValue: row[2])!,
                                    dates: Array(x),
                                    series: row.dropFirst(4).map { Double($0) ?? -1 }))
            } else {
                print("smth wrong in csv")
            }
        }
        print(trends)
        
        return trends
    }
    
}
