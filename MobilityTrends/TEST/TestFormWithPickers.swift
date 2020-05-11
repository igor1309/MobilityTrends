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
    @EnvironmentObject var territories: Territories
    
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
                    ForEach(territories.locales, id: \.self) { item in
                        Text(item)
                    }
                }
                
                Picker("Country", selection: $country) {
                    ForEach(territories.countries, id: \.self) { region in
                        Text(region.name)
                    }
                }
                
                Picker("City", selection: $city) {
                    ForEach(territories.cities, id: \.self) { region in
                        Text(region.name)
                    }
                }
                
                Picker("Sub-Region", selection: $subRegion) {
                    ForEach(territories.subRegions, id: \.self) { region in
                        Text(region.name)
                    }
                }
            }
            .navigationBarTitle(Text("Mobility Trends"), displayMode: .automatic)
            .navigationBarItems(trailing: TrailingButtonSFSymbol("arrow.2.circlepath") {
                self.store.fetch()
                self.territories.fetch()
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

