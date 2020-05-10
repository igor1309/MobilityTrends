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
    @EnvironmentObject var territories: Territories
    
    @Binding var region: String
    
    var body: some View {
        TrailingButtonSFSymbol(territories.isFavorite(region: region) ? "star.fill" : "star") {
            if self.territories.isFavorite(region: self.region) {
                self.territories.delete(region: self.region)
            } else {
                self.territories.add(region: self.region)
            }
        }
        .foregroundColor(territories.isFavorite(region: region) ? .systemOrange : .secondary)
    }
}

struct TrailingFavoriteToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        TrailingFavoriteToggleButton(region: .constant("Moscow"))
            .environmentObject(Territories())
    }
}
