//
//  CountryTrendsView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CountryTrendsHeader: View {
    @EnvironmentObject var store: Store

    var body: some View {
        HStack {
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
    @EnvironmentObject var favoriteRegions: FavoriteRegions
    
    let baseline: Double = 100
    
    var storeChecker: some View {
        VStack {
            Divider()
            Form {
                Section(header: Text("First five regions:".uppercased())) {
                    ForEach(store.allRegions.prefix(5), id: \.self) { region in
                        Text(region)
                    }
                }
                
                Section(header: Text("Favorite regions:".uppercased())) {
                    ForEach(favoriteRegions.regions, id: \.self) { region in
                        Text(region)
                    }
                }
            }
        }
        .foregroundColor(.secondary)
    }
    
    
    var body: some View {
        
        let minY = self.store.selectedRegionMinY
        let maxY = self.store.selectedRegionMaxY
        
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
                    ForEach(TransportType.allCases, id: \.self) { transportType in
                        Text("TBD%")
                            .foregroundColor(transportType.color)
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
                        .offset(y: geo.size.height / CGFloat(maxY - minY) * CGFloat((maxY + minY) / 2 - self.baseline) - 9)
                    //
                    /// legend
                    legend
                        .offset(y: geo.size.height / CGFloat(maxY - minY) * CGFloat((maxY + minY) / 2 - maLast))
                }
                .foregroundColor(.tertiary)
                .font(.caption)
            }
            .frame(width: 60)
        }
        
        return VStack {
            
            CountryTrendsHeader()
                        
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
            .padding(.top)
        }
        .padding(.horizontal)
    }
}

struct CountryTrendsView_Previews: PreviewProvider {
    static var previews: some View {
        CountryTrendsView()
            .environmentObject(Store())
            .environmentObject(FavoriteRegions())
    }
}
