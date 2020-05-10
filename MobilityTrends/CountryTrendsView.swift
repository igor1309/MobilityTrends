//
//  CountryTrendsView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct CountryTreRndsHeader: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        HStack(spacing: 16) {
            FavoriteRegionPicker(selectedRegion: $store.selectedRegion)
            RegionPicker(selectedRegion: $store.selectedRegion)
                .font(.headline)
            Spacer()
            FavoriteToggleButton(region: store.selectedRegion)
            FetchDataButton()
        }
        .padding(.vertical)
    }
}

struct CountryTrendsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var regions: Regions
    
    var body: some View {
        
        let minY = self.store.selectedRegionMinY
        let maxY = self.store.selectedRegionMaxY
        let maAvg: Double = store.lastMovingAverageAverage
        
        func lineGraph(transportType: TransportType) -> LineGraphShape {
            LineGraphShape(
                series: self.store.movingAverageSeries(
                    for: self.store.selectedRegion,
                    transportType: transportType),
                minY: minY,
                maxY: maxY)
        }
        
        func yScale(originalLast: Double, maLast: Double) -> some View {
            
            var legend: some View {
                VStack(alignment: .trailing) {
                    ForEach(store.lastMovingAveragesForSelectedRegion, id: \.self) { tail in
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
            CountryTreRndsHeader()
            
            if store.isNotEmpty {
                VStack {
                    
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
                                ForEach(TransportType.allCases, id: \.self) { transportType in
                                    
                                    lineGraph(transportType: transportType)
                                        .stroke(transportType.color, lineWidth: 2)
                                }
                            }
                            
                            yScale(originalLast: 10, maLast: 12)
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
        .environmentObject(Regions())
        .environment(\.colorScheme, .dark)
    }
}
