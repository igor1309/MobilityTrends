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
    @EnvironmentObject var territories: Territories
    
    var body: some View {
        VStack {
            CountryTrendsHeader()
            
            TransportTypePicker(selection: $store.transportType)
            
            if store.tide.trendsForSelected[store.transportType] != nil {
                OneLineChartView(
                    original: store.tide.trendsForSelected[store.transportType]!,
                    movingAverage: store.tide.movingAverageForSelected[store.transportType]!,
                    baseline: store.baseline,
                    minY: store.tide.selectedRegionMinY,
                    maxY: store.tide.selectedRegionMaxY
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
    }
}

struct SimpleChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            SimpleChartView()
        }
        .environmentObject(Store())
        .environmentObject(Territories())
        .environment(\.colorScheme, .dark)
    }
}
