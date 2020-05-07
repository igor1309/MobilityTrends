//
//  TestFormWithPickers.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct TestFormWithPickers: View {
    @EnvironmentObject var store: Store
    
    @State private var region: String = ""
    @State private var country: String = ""
    @State private var city: String = ""
    @State private var subRegion: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Text("CHANGE FILE NAME TO GET NEW DATA!!!")
                    .foregroundColor(.systemRed)
                
                Picker("Region", selection: $region) {
                    ForEach(store.allRegions, id: \.self) { item in
                        Text(item)
                    }
                }
                
                Picker("Country", selection: $country) {
                    ForEach(store.countries, id: \.self) { item in
                        Text(item)
                    }
                }
                
                Picker("City", selection: $city) {
                    ForEach(store.cities, id: \.self) { item in
                        Text(item)
                    }
                }
                
                Picker("Sub-Region", selection: $subRegion) {
                    ForEach(store.subRegions, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            .navigationBarTitle(Text("Mobility Trends"), displayMode: .automatic)
            .navigationBarItems(trailing: TrailingButtonSFSymbol("arrow.2.circlepath") {
                self.store.fetch()
            })
        }
    }
}

struct TestFormWithPickers_Previews: PreviewProvider {
    static var previews: some View {
        TestFormWithPickers()
            .environmentObject(Store())
            .environment(\.colorScheme, .dark)
    }
}

