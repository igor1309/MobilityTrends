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
    @EnvironmentObject var regions: Regions
    
    @State private var showSearch = false
    @State private var showFavorites = false
    
    var body: some View {
        NavigationView {
            VStack {
                TransportTypePicker(selection: $store.transportation)
                
                if store.originalSeries.isNotEmpty {
                    OneLineChartView(original: store.originalSeries,
                                     movingAverage: store.movingAverageSeries,
                                     baseline: store.baseline,
                                     minY: store.originalSeries.min()!,
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
                    
                    RegionPicker(selectedRegion: self.$store.selectedRegion)
                },
                trailing: HStack {
                    TrailingFavoriteToggleButton(region: $store.selectedRegion)
                    
                    TrailingButtonSFSymbol("text.badge.star") {
                        self.showFavorites = true
                    }
                    
                    TrailingButtonSFSymbol("arrow.2.circlepath") {
                        self.store.fetch()
                        self.regions.fetch()
                    }
            })
                .sheet(isPresented: $showFavorites) {
                    RegionsView(selected: self.$store.selectedRegion)
                        .environmentObject(self.store)
                        .environmentObject(self.regions)
            }
        }
    }
}

struct SimpleChartView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleChartView()
            .environmentObject(Store())
            .environmentObject(Regions())
    }
}
