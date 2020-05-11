//
//  GraphGridShape.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct GraphGridShape: InsettableShape {
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
    
    //  https://www.hackingwithswift.com/books/ios-swiftui/adding-strokeborder-support-with-insettableshape
    var insetAmount: CGFloat = 0
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var graphGridShape = self
        graphGridShape.insetAmount += amount
        return graphGridShape
    }
    
func path(in rect: CGRect) -> Path {
//        let stepY: CGFloat = rect.height / (maxY - minY)
        
        return Path { path in
            path.addLines([
                CGPoint(x: 0,
                        y: 0 + insetAmount),
                CGPoint(x: rect.width,
                        y: 0 + insetAmount)
            ])
            path.addLines([
                CGPoint(x: 0,
                        y: rect.height + insetAmount),
                CGPoint(x: rect.width,
                        y: rect.height + insetAmount)
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
