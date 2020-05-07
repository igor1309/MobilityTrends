//
//  BaseLineShape.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

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

struct BaseLineShape_Previews: PreviewProvider {
    static var previews: some View {
        BaseLineShape(series: [10,15,35,80,10,45], minY: -20, maxY: 250)
            .stroke()
    }
}
