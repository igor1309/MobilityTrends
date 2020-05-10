//
//  SimpleChartViewWithTide.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 11.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct SimpleChartViewWithTide: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var territories: Territories
    
    var body: some View {
        
        func chart(transport: TransportType) -> some View {
            Group {
                if store.tide.trendsForSelected[transport] != nil {
                    OneLineChartView(
                        original: store.tide.trendsForSelected[transport]!,
                        movingAverage: store.tide.movingAverageForSelected[transport]!,
                        baseline: store.baseline,
                        minY: store.tide.selectedRegionMinY,
                        maxY: store.tide.selectedRegionMaxY
                    )
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
        }
        
        return VStack {
            CountryTrendsHeader()
            
            TransportTypePicker(selection: $store.transportType)
            
            chart(transport: store.transportType)
                .padding(.top)
        }
        .padding(.horizontal)
    }
}

struct SimpleChartViewWithTide_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            SimpleChartViewWithTide()
        }
        .environmentObject(Store())
        .environmentObject(Territories())
        .environment(\.colorScheme, .dark)
    }
}
