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
    @State private var transportation = TransportationType.driving
    @State private var region = "Moscow"
    
    var regionPicker: some View {
        HStack {
            Button(action: {
                self.showSearch = true
            }) {
                Image(systemName: "chevron.down")
                    .font(.headline)
                Text(region)
            }
        }
        .sheet(isPresented: $showSearch) {
            NavigationView {
                SearchView(selection: self.$region)
            }
            .environmentObject(self.store)
        }
    }
    
    var body: some View {
        let originalSeries = store.series(for: region, transportationType: transportation)
        let movingAverageSeries = store.movingAverageSeries(for: region, transportationType: transportation)
        
        return VStack {
            Picker("Transportation Type", selection: $transportation) {
                ForEach(TransportationType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if originalSeries.isNotEmpty {
                ZStack {
                    LineGraphShape(series: movingAverageSeries)
                        .stroke(Color.systemOrange, lineWidth: 2)
                    
                    DotGraphShape(series: originalSeries)
                        .fill(Color.systemGray3)
                }
                .padding(.vertical)
            } else {
                VStack {
                    Text("No data for \(transportation.rawValue) in \(region)")
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
        SimpleChartView()
            .environmentObject(Store())
    }
}
