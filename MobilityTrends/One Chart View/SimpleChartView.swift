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
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
//                CountryTrendsHeader()
                
                TransportTypePicker(selection: $store.transportType)
                    .padding(.vertical, 8)
//                    .offset(y: -8)
                
                if store.trend.trendsForSelected[store.transportType] != nil {
                    OneLineChartView(
                        xLabels: store.trend.xLabelsForSelected,
                        original: store.trend.trendsForSelected[store.transportType]!,
                        movingAverage: store.trend.movingAverageForSelected[store.transportType]!,
                        baseline: store.baseline,
                        minY: store.trend.selectedRegionMinY,
                        maxY: store.trend.selectedRegionMaxY
                    )
                        .padding(.top)
                } else {
                    VStack {
                        Text("No data for \(store.transportType.rawValue) in \(store.selectedRegion)")
                            .padding(.top)
                            .foregroundColor(.systemRed)
                            .opacity(0.6)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .navigationBarTitle(Text(store.selectedRegion), displayMode: .inline)
            .navigationBarItems(
                leading: HStack {
                    LeadingRegionPickerButton(
                        selectedRegion: $store.selectedRegion
                    )
                    LeadingFavoriteRegionPickerButton(
                        selectedRegion: $store.selectedRegion
                    )
                },
                trailing: HStack {
                    TrailingFavoriteToggleButton(region: store.selectedRegion)
                        .environmentObject(self.settings)
                    
                    TrailingFetchDataButton()
                        .environmentObject(self.store)
            })
        }
    }
}

struct SimpleChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            SimpleChartView()
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
