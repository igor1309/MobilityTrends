//
//  ContentView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 06.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        TabView(selection: $settings.selectedTab) {
            
            NowView(
                data: store.currentMobility.mobilityIndex(geoType: store.selectedGeoType, transport: store.transportType),
                max: store.currentMobility.mobilityIndexMax(geoType: store.selectedGeoType, transport: store.transportType)
            )
                .tabItem {
                    Image(systemName: "text.alignleft")
                    Text("Now")
            }
            .tag(0)
            
            CountryTrendsView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("one")
            }
            .tag(1)
            
            SimpleChartView()
                .tabItem {
                    Image(systemName: "waveform.path")
                    Text("two")
            }
            .tag(2)
            
            FavoritesView()
//            SearchView(selection: $store.query)
                .tabItem {
                    Image(systemName: "star")// "magnifyingglass")
                    Text("Favs")//"Search")
            }
            .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Check")
            }
            .tag(4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Store())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
