//
//  RegionPicker.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct RegionPicker: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var territories: Territories
    @EnvironmentObject var settings: Settings
    
    @Binding var selectedRegion: String
    
    @State private var showSearch = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.showSearch = true
            }) {
                Image(systemName: "chevron.down")
                    .font(.headline)
                Text(selectedRegion)
                    .lineLimit(1)
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(selection: self.$selectedRegion)
                .environmentObject(self.store)
                .environmentObject(self.territories)
                .environmentObject(self.settings)
        }
    }
}

struct RegionPickerTester: View {
    @State private var selected = "Russia"
    
    var body: some View {
        VStack {
            RegionPicker(selectedRegion: $selected)
            Divider()
            RegionPicker(selectedRegion: $selected)
                .font(.headline)
            Divider()
            RegionPicker(selectedRegion: $selected)
                .font(.title)
        }
    }
}

struct RegionPicker_Previews: PreviewProvider {
    static var previews: some View {
        RegionPickerTester()
            .environmentObject(Store())
            .environmentObject(Territories())
            .environmentObject(Settings())
    }
}
