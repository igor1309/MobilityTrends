//
//  VerticalGrigLabels.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 01.06.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct VerticalGrigLabels: View {
    let xMax: CGFloat
    let periodicity: Periodicity
    
    var body: some View {
        GeometryReader { geometry in
            self.xLabels(width: geometry.size.width,
                         xMax: self.xMax,
                         periodicity: self.periodicity)
        }
        .padding(.vertical, 6)
        .fixedSize(horizontal: false, vertical: true)
        //            .background(Color.green)
    }
    
    func xLabels(width: CGFloat, xMax: CGFloat, periodicity: Periodicity) -> some View {
        let ticks = Array(stride(from: 0, through: xMax, by: periodicity.rawValue)).dropFirst()
        
        return ZStack {
            ForEach(ticks, id: \.self) { tick in
                HStack {
                    Spacer()
                    
                    Text("\(tick, specifier: "%.2f")")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .offset(x: width / xMax * (tick - xMax) - 3)
                }
            }
        }
    }
}

struct VerticalGrigLabels_Previews: PreviewProvider {
    static let xMax1: CGFloat = 1.3
    static let periodicity1: Periodicity = .quarter
    
    static let xMax2: CGFloat = 2.7
    static let periodicity2: Periodicity = .half
    
    static var previews: some View {
        Group {
            ZStack(alignment: .bottom) {
                VerticalGrid(xMax: xMax1, periodicity: periodicity1)
                    .stroke(Color.blue.opacity(0.5))
                
                VerticalGrigLabels(xMax: xMax1, periodicity: periodicity1)
            }
            
            ZStack(alignment: .bottom) {
                VerticalGrid(xMax: xMax2, periodicity: periodicity2)
                    .stroke(Color.blue.opacity(0.5))
                VerticalGrigLabels(xMax: xMax2, periodicity: periodicity2)
            }
        }
        .frame(height: 60)
        .previewColorSchemes(.dark)
    }
}
