//
//  FavoriteToggleButton.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct FavoriteToggleButton: View {
    @EnvironmentObject var favoriteRegions: FavoriteRegions
    
    var region: String
    
    var body: some View {
        let isFavorite = self.favoriteRegions.isFavorite(region: self.region)
        
        return Button(action: {
            self.favoriteRegions.toggleFavorite(region: self.region)
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .systemOrange : .secondary)
        }
    }
}

struct FavoriteToggleButtonTesting: View {
    @EnvironmentObject var favoriteRegions: FavoriteRegions
    
    @State private var region = "Moscow"
    
    var body: some View {
        VStack {
            HStack {
                Text(region)
                Spacer()
                FavoriteToggleButton(region: region)
            }
            .padding(.horizontal)
            
            List {
                ForEach(favoriteRegions.regions, id: \.self) { region in
                    Text(region)
                }
            }
        }
    }
}

struct FavoriteToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteToggleButtonTesting()
            .environmentObject(FavoriteRegions())
    }
}
