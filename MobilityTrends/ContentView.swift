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
    @State private var selectedTab: Int = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            
            CountryTrendsView()
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("one")
            }
            .tag(0)
            
            SimpleChartView()
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("two")
            }
            .tag(1)
            
            SearchViewTesting()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
            }
            .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Store())
            .environmentObject(Territories())
            .environment(\.colorScheme, .dark)
    }
}
