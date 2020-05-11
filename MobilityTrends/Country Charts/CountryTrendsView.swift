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
            
            return YScaleView(minY: minY, maxY: maxY, baseline: self.store.baseline, maLast: maAvg) {
                legend
            }
        }
        
        var sourceToggleButton: some View {
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
        }
        
        var transportLegend: some View {
            VStack(alignment: .leading) {
                ForEach(TransportType.allCases, id: \.self) { transportType in
                    Text(transportType.rawValue)
                        .foregroundColor(transportType.color)
                        .font(.footnote)
                }
            }
                .padding([.top])//, .leading])
        }
        
        return VStack {
            CountryTrendsHeader()
            
            if store.trend.isNotEmpty {
                
                ZStack(alignment: .topTrailing) {
                    
                    HStack(alignment: .top) {
                        transportLegend
                        Spacer()
                        sourceToggleButton
                    }
                    
                    VStack(spacing: 0) {
                        ZStack(alignment: .trailing) {
                            GraphGridShape(series: [100], minY: minY, maxY: maxY)
                                .strokeBorder(Color.systemGray3, lineWidth: 0.5)
                            
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
                        
                        XScaleView(labels: store.trend.xLabelsForSelected)
                    }
                }
            } else {
                Text("No data, please update")
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
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
