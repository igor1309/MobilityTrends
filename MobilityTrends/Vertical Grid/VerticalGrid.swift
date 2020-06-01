//
//  VerticalGrid.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 01.06.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct VerticalGrid: Shape {
    let xMax: CGFloat
    let periodicity: Periodicity
    
    init(xMax: CGFloat?, periodicity: Periodicity) {
        self.xMax = xMax ?? 1
        self.periodicity = periodicity
    }
    
    func path(in rect: CGRect) -> Path {
        let xStep = rect.width / xMax
        return Path { path in
            for tick in stride(from: 0, through: xMax, by: periodicity.rawValue) {
                let x: CGFloat = tick * xStep
                path.addLines([
                    CGPoint(x: x, y: rect.minY),
                    CGPoint(x: x, y: rect.maxY)
                ])
            }
        }
    }
}
struct VerticalGrid_Previews: PreviewProvider {
    static var previews: some View {
        VerticalGrid(xMax: 1.3, periodicity: .quarter)
            .stroke(Color.blue)
            .padding()
            .frame(height: 200)
            .previewColorSchemes(.dark)
    }
}
