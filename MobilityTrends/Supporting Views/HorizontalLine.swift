//
//  HorizontalLine.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 30.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addLines([
                CGPoint(x: 0, y: rect.midY),
                CGPoint(x: rect.maxX, y: rect.midY)
            ])
        }
    }
}

struct HorizontalLine_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalLine()
    }
}
