//
//  VerticalGridView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 01.06.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

private struct VerticalGridView: View {
    let xMax: CGFloat
    let periodicity: Periodicity
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                VerticalGrid(xMax: xMax, periodicity: .quarter)
                    .stroke(Color.blue.opacity(0.5))
                
                VerticalGrid(xMax: xMax, periodicity: periodicity)
                    .stroke(Color.orange)
            }
            
            VerticalGrigLabels(xMax: xMax, periodicity: periodicity)
        }
    }
}

private struct VerticalGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            VerticalGridView(xMax: 1.3, periodicity: .quarter)
            VerticalGridView(xMax: 5, periodicity: .half)
        }
        .padding()
            .frame(height: 200)
            .border(Color.pink)
            .previewColorSchemes(.dark)
    }
}
