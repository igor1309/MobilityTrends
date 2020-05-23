//
//  CountryTrendsHeader.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 11.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CountryTrendsHeader: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        HStack(spacing: 16) {
            FavoriteRegionPickerButton(
                selectedRegion: $store.selectedRegion
            )
            RegionPicker(
                selectedRegion: $store.selectedRegion
            )
                .font(.headline)
            
            Spacer()
            
            FavoriteToggleButton(region: store.selectedRegion)
            FetchDataButton()
        }
        .padding(.vertical)
    }
}

struct CountryTrendsHeader_Previews: PreviewProvider {
    static var previews: some View {
        CountryTrendsHeader()
            .environmentObject(Store())
    }
}
