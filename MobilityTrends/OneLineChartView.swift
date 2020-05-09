//
//  OneLineChartView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

//  FOR NON-EMPTY SERIES ONLY!!!
//  don't use with series that could be empty, always check before
struct OneLineChartView: View {

    var original: [Double]
    var movingAverage: [Double]
    var baseline: Double
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
        
        func yScale(originalLast: Double, maLast: Double) -> some View {
            
            var legend: some View {
                VStack(alignment: .trailing) {
                    if originalLast > maLast {
                        Text((originalLast/100).formattedPercentage)
                            .foregroundColor(.secondary)
                        
                        Text((maLast/100).formattedPercentage)
                            .foregroundColor(.systemOrange)
                    } else {
                        Text((maLast/100).formattedPercentage)
                            .foregroundColor(.systemOrange)
                        
                        Text((originalLast/100).formattedPercentage)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.caption)
            }
            
            return GeometryReader { geo in
                ZStack(alignment: .trailing) {
                    /// min
                    Text(self.minY.formattedGrouped)
                        .offset(y: geo.size.height / 2 - 9)
                    
                    /// max
                    Text(self.maxY.formattedGrouped)
                        .offset(y: -geo.size.height / 2 - 9)
                    
                    /// baseline
                    Text("Baseline")
                        .fixedSize()
                        .offset(y: geo.size.height / CGFloat(self.maxY - self.minY) * CGFloat((self.maxY + self.minY) / 2 - self.baseline) - 9)
                    
                    /// legend
                    legend
                        .offset(y: geo.size.height / CGFloat(self.maxY - self.minY) * CGFloat((self.maxY + self.minY) / 2 - maLast))
                }
                .foregroundColor(.tertiary)
                .font(.caption)
            }
            .frame(width: 60)
        }
        
        return ZStack {
            GraphGridShape(series: original, minY: minY, maxY: maxY)
                .stroke(Color.systemGray3, lineWidth: 0.5)
            
            BaseLineShape(series: original, minY: minY, maxY: maxY)
                .stroke(Color.systemGray3)
            
            HStack(spacing: -20) {
                
                originalAndMovingAverageGraph(original: original,
                                              movingAverage: movingAverage,
                                              minY: minY,
                                              maxY: maxY)
                
                yScale(originalLast: original.last!, maLast: movingAverage.last!)
            }
        }
    }
}

struct OneLineChartView_Previews: PreviewProvider {
    static var original: [Double] = [100.0, 103.68, 103.65, 108.89, 116.36, 116.93, 106.76, 107.77, 113.98, 114.99, 110.96, 120.76, 116.22, 110.39, 116.79, 116.99, 112.24, 116.27, 120.51, 113.43, 107.37, 108.62, 111.77, 115.24, 116.29, 119.21, 120.2, 113.89, 120.79, 121.17, 124.75, 124.48, 136.13, 126.69, 115.6, 117.48, 123.64, 124.96, 132.27, 147.4, 131.41, 97.9, 119.27, 117.85, 124.96, 129.72, 130.6, 123.44, 113.48, 111.82, 120.69, 120.5, 130.26, 139.98, 126.41, 97.02, 121.58, 117.18, 123.05, 121.8, 120.16, 116.09, 97.38, 104.65, 109.37, 102.78, 100.31, 102.02, 82.47, 78.48, 82.86, 88.58, 89.52, 95.56, 108.8, 66.65, 53.16, 42.27, 37.69, 36.88, 37.56, 40.03, 35.27, 36.7, 42.15, 44.73, 45.37, 48.39, 47.41, 42.24, 43.0, 41.42, 42.52, 34.39, 34.13, 34.88, 30.58, 31.62, 37.1, 38.26, 36.67, 38.49, 38.97, 35.79, 38.34, 41.7, 44.05, 46.03, 52.7, 43.4, 41.44, 41.08, 39.32, 44.18]
    static var movingAverage: [Double] = [100.0, 101.84, 102.44333333333334, 104.055, 106.516, 108.25166666666667, 108.03857142857143, 109.14857142857143, 110.62, 112.24000000000001, 112.53571428571429, 113.16428571428571, 113.06285714285715, 113.58142857142857, 114.86999999999999, 115.29999999999998, 114.90714285714286, 115.66571428571429, 115.63, 115.2314285714286, 114.8, 113.63285714285715, 112.88714285714285, 113.3157142857143, 113.31857142857143, 113.13285714285713, 114.10000000000001, 115.03142857142858, 116.77, 118.11285714285714, 119.47142857142856, 120.64142857142858, 123.05857142857143, 123.9857142857143, 124.23, 123.75714285714287, 124.11, 124.14, 125.25285714285714, 126.86285714285714, 127.53714285714284, 125.00857142857141, 125.2642857142857, 124.43714285714285, 124.43714285714286, 124.07285714285716, 121.67285714285715, 120.53428571428572, 122.75999999999999, 121.69571428571427, 122.10142857142857, 121.46428571428571, 121.54142857142857, 122.88142857142859, 123.30571428571429, 120.9542857142857, 122.34857142857142, 121.84714285714287, 122.21142857142857, 121.00285714285712, 118.17142857142856, 116.69714285714285, 116.74857142857142, 114.33000000000001, 113.21428571428571, 110.31857142857142, 107.24857142857142, 104.65714285714284, 99.85428571428572, 97.15428571428572, 94.04142857142858, 91.07142857142858, 89.17714285714285, 88.49857142857142, 89.46714285714286, 87.20714285714284, 83.59, 77.79142857142857, 70.52142857142856, 63.00142857142856, 54.715714285714284, 44.89142857142857, 40.40857142857143, 38.057142857142864, 38.04, 39.04571428571428, 40.25857142857143, 41.80571428571428, 42.86, 43.855714285714285, 44.755714285714284, 44.651428571428575, 44.33571428571428, 42.76714285714285, 40.730000000000004, 38.94, 37.27428571428571, 35.64857142857143, 35.03142857142857, 34.42285714285715, 34.74857142857143, 35.371428571428574, 35.955714285714286, 36.699999999999996, 37.660000000000004, 38.31714285714286, 39.144285714285715, 40.48142857142857, 42.511428571428574, 43.144285714285715, 43.951428571428565, 44.34285714285715, 44.00285714285714, 44.021428571428565]
    
    static var previews: some View {
        OneLineChartView(original: original, movingAverage: movingAverage, baseline: 100, minY: original.min()!, maxY: original.max()!)
    }
}
