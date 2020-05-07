//
//  OneLineChartView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

//  FOR NON-EMPTY SERIES ONLY!!!
struct OneLineChartView: View {
    var original: [Double]
    var movingAverage: [Double]
    var minY: Double
    var maxY: Double
    
    var body: some View {
        
        func originalAndMovingAverageGraph(original: [Double], movingAverage: [Double], minY: Double, maxY: Double) -> some View {
            
            ZStack {
                DotGraphShape(series: original, minY: minY, maxY: maxY)
                    .fill(Color.systemGray3)
                
                LineGraphShape(series: original, minY: minY, maxY: maxY)
                    .stroke(Color.systemGray4, lineWidth: 0.5)
                
                LineGraphShape(series: movingAverage, minY: minY, maxY: maxY)
                    .stroke(Color.systemOrange, lineWidth: 2)
                
            }
        }
        
        var yScale: some View {
            ZStack(alignment: .leading) {
                Text("???")
                    .offset(y: 200)
                
                Text("Baseline")
                
                
                Text("?????")
                    .offset(y: -100)
            }
            .foregroundColor(.secondary)
            .font(.caption)
        }
        
        func simpleLegend(originalLast: Double, maLast: Double) -> some View {
            VStack(alignment: .trailing) {
                Text((originalLast/100).formattedPercentage)
                    .foregroundColor(.secondary)
                
                Text((maLast/100).formattedPercentage)
                    .foregroundColor(.systemOrange)
            }
            .font(.caption)
        }
        
        return ZStack {
            GraphGridShape(series: original, minY: minY, maxY: maxY)
                .stroke(Color.green)
            
            BaseLineShape(series: original, minY: minY, maxY: maxY)
                .stroke(Color.blue)//systemGray3)
            
            HStack(spacing: 0) {
                yScale
                
                originalAndMovingAverageGraph(original: original, movingAverage: movingAverage, minY: minY, maxY: maxY)
                
                simpleLegend(originalLast: original.last!, maLast: movingAverage.last!)
            }
        }
    }
}

struct OneLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        OneLineChartView(original: [10,15,35,80,10,45], movingAverage: [10,15,25,76,25,35], minY: -20, maxY: 100)
    }
}
