//
//  CountryTrendsView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct CountryTrendsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var territories: Territories
    
    @State private var isUsingMovingAverage = true
    
    var body: some View {
        
        let series: [TransportType : [Double]]
        if isUsingMovingAverage {
            series = store.trend.movingAverageForSelected
        } else {
            series = store.trend.trendsForSelected
        }
        
        
        let minY = store.trend.selectedRegionMinY
        let maxY = store.trend.selectedRegionMaxY
        let maAvg = store.trend.lastMovingAverageAverage
        
        func lineGraph(series: [Double], transport: TransportType) -> some View {
            Group {
                if series.isNotEmpty {
                    LineGraphShape(series: series, minY: minY, maxY: maxY)
                        .stroke(transport.color, lineWidth: 2)
                } else {
                    EmptyView()
                }
            }
        }
        
        var yScale: some View {
            
            var legend: some View {
                VStack(alignment: .trailing) {
                    ForEach(store.trend.lastMovingAveragesForSelectedRegion, id: \.self) { tail in
                        Text((tail.last/100).formattedPercentage)
                            .foregroundColor(tail.type.color)
                            .font(.footnote)
                    }
                }
                .font(.caption)
            }
            
            return GeometryReader { geo in
                ZStack(alignment: .trailing) {
                    /// min
                    Text(minY.formattedGrouped)
                        .offset(y: geo.size.height / 2 - 9)
                    
                    /// max
                    Text(maxY.formattedGrouped)
                        .offset(y: -geo.size.height / 2 - 9)
                    
                    /// baseline
                    Text("Baseline")
                        .fixedSize()
                        .offset(y: geo.size.height / CGFloat(maxY - minY) * CGFloat((maxY + minY) / 2 - self.store.baseline) - 9)
                    //
                    /// legend
                    legend
                        .offset(y: geo.size.height / CGFloat(maxY - minY) * CGFloat((maxY + minY) / 2 - maAvg) - 9)
                }
                .foregroundColor(.tertiary)
                .font(.caption)
            }
            .frame(width: 60)
        }
        
        
        return VStack {
            CountryTrendsHeader()
            
            if store.trend.isNotEmpty {
                
                ZStack(alignment: .topTrailing) {
                    
                    Button(action : {
                        self.isUsingMovingAverage.toggle()
                    }) {
                        Image(systemName: isUsingMovingAverage ? "waveform.path" : "waveform.path.ecg")
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.quaternarySystemFill)
                        )
                            .padding(.top)
                    }
                    
                    ZStack(alignment: .topLeading) {
                        
                        VStack(alignment: .leading) {
                            ForEach(TransportType.allCases, id: \.self) { transportType in
                                Text(transportType.rawValue)
                                    .foregroundColor(transportType.color)
                                    .font(.footnote)
                            }
                        }
                        .padding()
                        
                        GraphGridShape(series: [100], minY: minY, maxY: maxY)
                            .stroke(Color.systemGray3, lineWidth: 0.5)
                        
                        BaseLineShape(series: [100], minY: minY, maxY: maxY)
                            .stroke(Color.systemGray3)
                        
                        HStack(spacing: -20) {
                            ZStack {
                                ForEach(TransportType.allCases, id: \.self) { transport in
                                    lineGraph(series: series[transport] ?? [], transport: transport)
                                }
                            }
                            
                            yScale
                        }
                    }
                }
            } else {
                Text("No date, please update")
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct CountryTrendsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CountryTrendsView()
        }
        .environmentObject(Store())
        .environmentObject(Territories())
        .environment(\.colorScheme, .dark)
    }
}
