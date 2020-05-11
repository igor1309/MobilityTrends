//
//  HomeSearchView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 11.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct HomeSearchView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var territories: Territories
    
    struct Terr: Identifiable {
        var id = UUID()
        var name: String
    }
    
    var body: some View {
        
        let terr = Binding<Terr?>(
            get: { nil },
            set: { self.store.selectedRegion = $0?.name ?? "Moscow" }
        )
        
        let name = Binding<String>(
            get: { terr.wrappedValue?.name ?? "Moscow" },
            set: {
                print("name is set to \($0)")
                print("terr: \(terr)")
                self.store.selectedRegion = $0
                terr.wrappedValue?.name = $0
        }
        )
        
        return SearchView(selection: name)
            
            .sheet(item: terr, onDismiss: {
                terr.wrappedValue = nil
            }) {_ in
                CountryTrendsView()
        }
    }
}


struct HomeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            HomeSearchView()
        }
        .environmentObject(Store())
        .environmentObject(Territories())
        .environment(\.colorScheme, .dark)
        
    }
}
