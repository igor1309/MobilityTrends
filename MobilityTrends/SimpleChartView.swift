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
    
    var body: some View {
        VStack {
            Picker("Transportation Type", selection: $store.transportation) {
                ForEach(TransportType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if store.originalSeries.isNotEmpty {
                ZStack {
                    BaseLineShape(series: store.originalSeries, minY: store.originalSeries.min()!, maxY: store.originalSeries.max()!)
                        .stroke()
                    
                    DotGraphShape(series: store.originalSeries, minY: store.originalSeries.min()!, maxY: store.originalSeries.max()!)
                        .fill(Color.systemGray3)
                    
                    LineGraphShape(series: store.originalSeries, minY: store.originalSeries.min()!, maxY: store.originalSeries.max()!)
                        .stroke(Color.systemGray4, lineWidth: 0.5)
                    
                    LineGraphShape(series: store.movingAverageSeries, minY: store.originalSeries.min()!, maxY: store.originalSeries.max()!)
                        .stroke(Color.systemOrange, lineWidth: 2)
                }
                .padding(.vertical)
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

struct TrailingFavoriteToggleButton: View {
    @EnvironmentObject var favoriteRegions: FavoriteRegions

    @Binding var region: String
    
    var body: some View {
        TrailingButtonSFSymbol(favoriteRegions.isFavorite(region: region) ? "star.fill" : "star") {
            if self.favoriteRegions.isFavorite(region: self.region) {
                self.favoriteRegions.delete(region: self.region)
            } else {
                self.favoriteRegions.add(region: self.region)
            }
        }
        .foregroundColor(favoriteRegions.isFavorite(region: region) ? .systemOrange : .secondary)
    }
}
