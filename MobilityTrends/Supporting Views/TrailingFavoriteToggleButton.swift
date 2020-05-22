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
    @EnvironmentObject var settings: Settings
    
    @Binding var region: String
    
    var body: some View {
        TrailingButtonSFSymbol(settings.isFavorite(region: region) ? "star.fill" : "star") {
            if self.settings.isFavorite(region: self.region) {
                self.settings.delete(region: self.region)
            } else {
                self.settings.add(region: self.region)
            }
        }
        .foregroundColor(settings.isFavorite(region: region) ? .systemOrange : .secondary)
    }
}

struct TrailingFavoriteToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        TrailingFavoriteToggleButton(region: .constant("Moscow"))
            .environmentObject(Settings())
    }
}
