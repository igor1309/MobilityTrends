//
//  SimpleChartView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct SimpleChartView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var favoriteRegions: FavoriteRegions
    
    @State private var showSearch = false
    @State private var showFavorites = false
    
    var regionPicker: some View {
        HStack {
            Button(action: {
                self.showSearch = true
            }) {
                Image(systemName: "chevron.down")
                    .font(.headline)
                Text(store.selectedRegion)
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(selection: self.$store.selectedRegion)
                .environmentObject(self.store)
        }
    }
    
    func chart(original: [Double], movingAverage: [Double], minY: Double, maxY: Double) -> some View {
        
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
    
    var body: some View {
        VStack {
            TransportTypePicker(selection: $store.transportation)
            
            if store.originalSeries.isNotEmpty {
                chart(original: store.originalSeries,
                      movingAverage: store.movingAverageSeries,
                      minY:  store.originalSeries.min()!,
                      maxY: store.originalSeries.max()!)
                    .padding(.top)
            } else {
                VStack {
                    Text("No data for \(store.transportation.rawValue) in \(store.selectedRegion)")
                        .padding(.top)
                        .foregroundColor(.systemRed)
                        .opacity(0.6)
                    Spacer()
                }
            }
        }
        .padding()
        .navigationBarTitle(Text("Mobility Trends"), displayMode: .large)
        .navigationBarItems(
            leading: HStack {
                LeadingButtonSFSymbol("text.badge.star") {
                    self.showFavorites = true
                }
                
                regionPicker
            },
            trailing: HStack {
                TrailingFavoriteToggleButton(region: $store.selectedRegion)
                
                TrailingButtonSFSymbol("text.badge.star") {
                    self.showFavorites = true
                }
                
                TrailingButtonSFSymbol("arrow.2.circlepath") {
                    self.store.fetch()
                }
        })
            .sheet(isPresented: $showFavorites) {
                FavoriteRegionsView(selected: self.$store.selectedRegion)
                    .environmentObject(self.store)
                    .environmentObject(self.favoriteRegions)
        }
    }
}

struct SimpleChartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SimpleChartView()
        }
        .environmentObject(Store())
        .environmentObject(FavoriteRegions())
    }
}
