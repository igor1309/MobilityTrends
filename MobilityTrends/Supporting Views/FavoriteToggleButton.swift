//
//  FavoriteToggleButton.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct FavoriteToggleButton: View {
    @EnvironmentObject var regions: Regions
    
    var region: String
    
    var body: some View {
        let isFavorite = self.regions.isFavorite(region: self.region)
        
        return Button(action: {
            self.regions.toggleFavorite(region: self.region)
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .systemOrange : .secondary)
        }
    }
}

struct FavoriteToggleButtonTesting: View {
    @EnvironmentObject var regions: Regions
    
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
                ForEach(regions.favorites, id: \.self) { region in
                    Text(region)
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
        .environmentObject(Regions())
    }
}
