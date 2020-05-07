//
//  LineGraphShape.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LineGraphShape: Shape {
    var series: [Double]
    let minY: CGFloat
    let maxY: CGFloat
    
    init(series: [Double], minY: Double? = nil, maxY: Double? = nil) {
        self.series = series
        if series.isEmpty {
            self.minY = 0
            self.maxY = 1
        } else {
            self.minY = CGFloat(minY ?? series.min()!)
            self.maxY = CGFloat(maxY ?? series.max()!)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        guard series.isNotEmpty else {
            return Path()
        }
        
        let stepX: CGFloat = rect.width / CGFloat(series.count - 1)
        let stepY: CGFloat = rect.height / (maxY - minY)
        
        func point(i: Int) -> CGPoint {
            CGPoint(x: CGFloat(i) * stepX,
                    y: rect.height - (CGFloat(series[i]) - minY) * stepY)
        }
        
        return Path { path in
            path.move(to: point(i: 0))
            
            for i in 1..<series.count {
                path.addLine(to: point(i: i))
            }
        }
    }
}

struct LineGraphShape_Previews: PreviewProvider {
    static var previews: some View {
        LineGraphShape(series: [10,15,35,80,10,45], minY: -20, maxY: 100)
            .stroke()
    }
}


///  Baseline at 100
struct BaseLineShape: Shape {
    let minY: CGFloat
    let maxY: CGFloat
    
    init(series: [Double], minY: Double? = nil, maxY: Double? = nil) {
        if series.isEmpty {
            self.minY = 0
            self.maxY = 1
        } else {
            self.minY = CGFloat(minY ?? series.min()!)
            self.maxY = CGFloat(maxY ?? series.max()!)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let stepY: CGFloat = rect.height / (maxY - minY)
        
        return Path { path in
            path.addLines([
                CGPoint(x: 0,
                        y: rect.height - (100 - minY) * stepY),
                CGPoint(x: rect.width,
                        y: rect.height - (100 - minY) * stepY)
            ])
        }
    }
}
