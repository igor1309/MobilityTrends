//
//  SlightlyRoundedRectangle.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 30.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct SlightlyRoundedRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: max(rect.width, rect.height) * 0.05)
            .path(in: rect)
    }
}

struct SlightlyRoundedRectangle_Previews: PreviewProvider {
    static var previews: some View {
        SlightlyRoundedRectangle()
    }
}
