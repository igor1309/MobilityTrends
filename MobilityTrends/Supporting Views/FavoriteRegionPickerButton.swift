//
//  LeadingFavoriteRegionPickerButton.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LeadingFavoriteRegionPickerButton: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @Binding var selectedRegion: String
    
    @State private var showFavorites = false
    
    var body: some View {
        Button(action: {
            self.showFavorites = true
        }) {
            Image(systemName: "text.badge.star")
                .padding(.vertical)
                .padding(.trailing, 8)
        }
        .sheet(isPresented: $showFavorites) {
            RegionsView(selected: self.$selectedRegion)
                .environmentObject(self.store)
                .environmentObject(self.settings)
        }
    }
}

struct FavoriteRegionPickerButton: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
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
                .environmentObject(self.settings)
        }
    }
}

struct LeadingFavoriteRegionPickerButtonTester: View {
    @State private var selected = "Russia"
    
    var body: some View {
        VStack {
            LeadingFavoriteRegionPickerButton(selectedRegion: $selected)
            
            FavoriteRegionPickerButton(selectedRegion: $selected)
        }
    }
}

struct LeadingFavoriteRegionPickerButton_Previews: PreviewProvider {
    static var previews: some View {
        LeadingFavoriteRegionPickerButtonTester()
            .environmentObject(Store())
    }
}
