//
//  TrailingFavoriteToggleButton.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct TrailingFavoriteToggleButton: View {
    @EnvironmentObject var regions: Regions
    
    @Binding var region: String
    
    var body: some View {
        TrailingButtonSFSymbol(regions.isFavorite(region: region) ? "star.fill" : "star") {
            if self.regions.isFavorite(region: self.region) {
                self.regions.delete(region: self.region)
            } else {
                self.regions.add(region: self.region)
            }
        }
        .foregroundColor(regions.isFavorite(region: region) ? .systemOrange : .secondary)
    }
}

struct TrailingFavoriteToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        TrailingFavoriteToggleButton(region: .constant("Moscow"))
            .environmentObject(Regions())
    }
}
