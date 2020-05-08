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
    @EnvironmentObject var favoriteRegions: FavoriteRegions
    
    @Binding var region: String
    
    var body: some View {
        TrailingButtonSFSymbol(favoriteRegions.isFavorite(region: region) ? "star.fill" : "star") {
            if self.favoriteRegions.isFavorite(region: self.region) {
                self.favoriteRegions.delete(region: self.region)
            } else {
                self.favoriteRegions.add(region: self.region)
            }
        }
        .foregroundColor(favoriteRegions.isFavorite(region: region) ? .systemOrange : .secondary)
    }
}

struct TrailingFavoriteToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        TrailingFavoriteToggleButton(region: .constant("Moscow"))
            .environmentObject(FavoriteRegions())
    }
}
