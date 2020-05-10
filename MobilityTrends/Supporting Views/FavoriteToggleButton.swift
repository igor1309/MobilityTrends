//
//  FavoriteToggleButton.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct FavoriteToggleButton: View {
    @EnvironmentObject var territories: Territories
    
    var region: String
    
    var body: some View {
        let isFavorite = self.territories.isFavorite(region: self.region)
        
        return Button(action: {
            self.territories.toggleFavorite(region: self.region)
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .systemOrange : .secondary)
        }
    }
}

struct FavoriteToggleButtonTesting: View {
    @EnvironmentObject var territories: Territories
    
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
                ForEach(territories.favorites, id: \.self) { favorite in
                    Text(favorite)
                }
            }
        }
    }
}

struct FavoriteToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FavoriteToggleButton(region: "Moscow")
            FavoriteToggleButtonTesting()
        }
        .environmentObject(Territories())
    }
}
