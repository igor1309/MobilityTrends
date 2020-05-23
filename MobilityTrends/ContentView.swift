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
            
            CountryTrendsView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("one")
            }
            .tag(0)
            
            SimpleChartView()
                .tabItem {
                    Image(systemName: "waveform.path")
                    Text("two")
            }
            .tag(1)
            
            SearchView(selection: $store.query)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
            }
            .tag(2)
            
            NowView(data: store.currentMobilityIndex)
                .tabItem {
                    Image(systemName: "text.alignleft")
                    Text("Now")
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
