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
    var body: some View {
        CountryTrendsView()
//                SearchViewTesting()
//                SimpleChartView()
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
