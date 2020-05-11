//
//  YScaleView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 12.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct YScaleView<Content: View>: View {
    
    let minY: Double
    let maxY: Double
    let baseline: Double
    let maLast: Double
    let legend: () -> Content
    
    init(minY: Double, maxY: Double, baseline: Double, maLast: Double, @ViewBuilder legend: @escaping () -> Content) {
        self.minY = minY
        self.maxY = maxY
        self.baseline = baseline
        self.maLast = maLast
        self.legend = legend
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                Group {
                    /// minY
                    Text(self.minY.formattedGrouped)
                        .offset(y: geo.size.height / 2 - 9)
                    
                    /// max
                    Text(self.maxY.formattedGrouped)
                        .offset(y: -geo.size.height / 2 - 9)
                    
                    /// baseline
                    Text("Baseline")
                        .fixedSize()
                        .offset(y: geo.size.height / CGFloat(self.maxY - self.minY) * CGFloat((self.maxY + self.minY) / 2 - self.baseline) - 9)
                    
                }
                .opacity(0.7)
                
                /// legend
                self.legend()
                    .offset(y: geo.size.height / CGFloat(self.maxY - self.minY) * CGFloat((self.maxY + self.minY) / 2 - self.maLast) - 9)
            }
            .foregroundColor(.secondary)
            .font(.caption)
        }
        .frame(width: 60)
    }
}

struct YScaleViewTesting: View {
    var body: some View {
        YScaleView(minY: 20, maxY: 150, baseline: 100, maLast: 34) {
            Text("this is\nlegend")
                .foregroundColor(.systemYellow)
        }
    }
}

struct YScaleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            HStack {
                Rectangle()
                    .fill()
                    .opacity(0.1)
                
                YScaleViewTesting()
            }
        }
        .environment(\.colorScheme, .dark)
    }
}
