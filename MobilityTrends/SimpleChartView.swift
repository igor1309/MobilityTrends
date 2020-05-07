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
    
    @State private var showSearch = false
    
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
            NavigationView {
                SearchView(selection: self.$store.selectedRegion)
            }
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
                    LineGraphShape(series: store.movingAverageSeries, minY: store.originalSeries.min()!, maxY: store.originalSeries.max()!)
                        .stroke(Color.systemOrange, lineWidth: 2)
                    
                    DotGraphShape(series: store.originalSeries, minY: store.originalSeries.min()!, maxY: store.originalSeries.max()!)
                        .fill(Color.systemGray3)
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
            leading: regionPicker,
            trailing: TrailingButtonSFSymbol("arrow.2.circlepath") {
                self.store.fetch()
        })
    }
}

struct SimpleChartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SimpleChartView()
        }
        .environmentObject(Store())
    }
}
