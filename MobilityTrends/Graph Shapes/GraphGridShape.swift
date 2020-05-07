//
//  GraphGridShape.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct GraphGridShape: Shape {
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
                        y: 0),
                CGPoint(x: rect.width,
                        y: 0)
            ])
            path.addLines([
                CGPoint(x: 0,
                        y: rect.height),
                CGPoint(x: rect.width,
                        y: rect.height)
            ])
        }
    }
}

struct GraphGridShape_Previews: PreviewProvider {
    static var previews: some View {
        GraphGridShape(series: [10,15,35,80,10,45], minY: -20, maxY: 250)
            .stroke()
    }
}
