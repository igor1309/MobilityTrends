//
//  FetchDataButton.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct FetchDataButton: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var territories: Territories
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        Button(action: {
            print("version: \(self.settings.version)")
            self.store.fetch(version: self.settings.version)
            self.territories.fetch(version: self.settings.version)
        }) {
            Image(systemName: store.updateStatus.icon)
            .foregroundColor(store.updateStatus.color)
            .rotationEffect(.degrees(store.updateStatus.isUpdating ? 180 : 0))
            .animation(store.updateStatus.isUpdating ? Animation.linear.repeatForever(autoreverses: false) : .default)
        }
    }
}

struct FetchDataButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FetchDataButton()
        }
        .environmentObject(Store())
        .environmentObject(Territories())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
