//
//  RegionPickerButton.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 23.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

import SwiftUI

struct LeadingRegionPickerButton: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @Binding var selectedRegion: String
    
    @State private var showSearch = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.showSearch = true
            }) {
                Image(systemName: "increase.indent")
                .offset(y: 1)
                    .padding(.vertical)
                    .padding(.trailing, 8)
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(selection: self.$selectedRegion)
                .environmentObject(self.store)
                .environmentObject(self.settings)
        }
    }
}

struct RegionPickerButton: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @Binding var selectedRegion: String
    
    @State private var showSearch = false
    
    var body: some View {
        HStack {
            Button(action: {
                self.showSearch = true
            }) {
                Image(systemName: "increase.indent")
                .offset(y: 1)
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(selection: self.$selectedRegion)
                .environmentObject(self.store)
                .environmentObject(self.settings)
        }
    }
}

struct RegionPickerButtonTester: View {
    @State private var selected = "Russia"
    
    var body: some View {
        VStack {
            RegionPickerButton(selectedRegion: $selected)
            Divider()
            RegionPickerButton(selectedRegion: $selected)
                .font(.headline)
            Divider()
            RegionPickerButton(selectedRegion: $selected)
                .font(.title)
        }
    }
}

struct RegionPickerButton_Previews: PreviewProvider {
    static var previews: some View {
        RegionPickerButtonTester()
            .environmentObject(Store())
            .environmentObject(Settings())
    }
}
