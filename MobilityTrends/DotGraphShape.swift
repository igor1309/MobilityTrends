//
//  DotGraphShape.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct DotGraphShape: Shape {
    var series: [Double]
    let minY: CGFloat
    let maxY: CGFloat
    let radius: CGFloat
    
    init(series: [Double], radius: CGFloat = 2, minY: Double? = nil, maxY: Double? = nil) {
        self.series = series
        self.radius = radius
        
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
        
        func ellipseRect(for point: CGPoint) -> CGRect {
            CGRect(x: point.x - radius,
                   y: point.y - radius,
                   width: 2 * radius,
                   height: 2 * radius)
        }
        
        return Path { path in
            for i in 0..<series.count {
                path.addEllipse(in: ellipseRect(for: point(i: i)))
            }
        }
    }
}

struct DotGraphShape_Previews: PreviewProvider {
    static var previews: some View {
        DotGraphShape(series: [10,15,35,80,10,45], radius: 8, minY: -20, maxY: 100)
            .fill()
    }
}
