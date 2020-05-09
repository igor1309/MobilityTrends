//
//  FavoriteRegionPicker.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct FavoriteRegionPicker: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var regions: Regions
    
    @Binding var selectedRegion: String
    
    @State private var showFavorites = false
    
    var body: some View {
        Button(action: {
            self.showFavorites = true
        }) {
            Image(systemName: "text.badge.star")
        }
        .sheet(isPresented: $showFavorites) {
            RegionsView(selected: self.$selectedRegion)
                .environmentObject(self.store)
                .environmentObject(self.regions)
        }
    }
}

struct FavoriteRegionPickerTester: View {
    @State private var selected = "Russia"
    
    var body: some View {
        FavoriteRegionPicker(selectedRegion: $selected)
    }
}

struct FavoriteRegionPicker_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteRegionPickerTester()
            .environmentObject(Store())
            .environmentObject(Regions())
    }
}
