//
//  LineChartCard.swift
//  TestingAreaCharts
//
//  Created by Igor Malyarov on 25.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import ChartsLibrary
import CollectionLibrary

enum ChartCardOptions: String, CaseIterable { case original, movingAverage, both}

struct LineChartCard: View {
    let element: Elementable
    var options: ChartCardOptions = .both
    
    var body: some View {
        VStack(alignment: .leading) {
            CardView {
                ZStack {
                    if self.options != .movingAverage {
                        LineChartView(series: self.element.series,
                                      isZeroBased: true,
                                      strokeContent: Color.tertiary)
                    }
                    
                    if self.options != .original {
                        MovingAverageLineChartView(series: self.element.series,
                                                   isZeroBased: true,
                                                   strokeContent: Color.systemOrange,
                                                   lineWidth: 2)
                    }
                }
                .aspectRatio(3/4, contentMode: .fit)
                .frame(height: 120)
            }
            
            Text(self.element.header)
                .font(.caption)
            Text(self.element.subheader)
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

struct LineChartCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ForEach(ChartCardOptions.allCases, id: \.self) { options in
                VStack {
                    Text(options.rawValue)
                        .font(.caption)
                    
                    LineChartCard(
                        element: CollectionElement(
                            header: "driving",
                            subheader: options.rawValue,
                            series: series),
                        options: options)
                }
            }
        }
        .padding()
        .previewColorSchemes()
        //        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        //        .environment(\.colorScheme, .dark)
        //        .previewLayout(.sizeThatFits)
        //        .previewAsComponent()
    }
}
