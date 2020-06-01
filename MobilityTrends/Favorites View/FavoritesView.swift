//
//  FavoritesView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 01.06.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import CollectionLibrary

struct FavoritesView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @State private var showChart = false
    
    var body: some View {
        NavigationView {
            
            CollectionView2(collection: store.collection(for: settings.favorites)) { row in
                
                CollectionRowView(collectionRow: row) { element in
                    
                    LineChartCard(element: element)
                        .onTapGesture {
                            self.store.selectedRegion = row.title
                            self.store.transportType = TransportType(rawValue: element.subheader) ?? .driving
                            self.showChart = true
                    }
                }
            }
            .sheet(isPresented: $showChart) {
                SimpleChartView()
                    .environmentObject(self.store)
                    .environmentObject(self.settings)
            }
//            CollectionView(collection: store.collection(for: settings.favorites)) { element in
//
//                LineChartCard(element: element)
//            }
            .padding(.vertical, 8)
            .navigationBarTitle("Mobility (favorites)", displayMode: .inline)
            .navigationBarItems(
                leading: LeadingFavoriteRegionPickerButton(
                    selectedRegion: $store.selectedRegion
                ),
                trailing: TrailingFetchDataButton()
            )
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(Store())
            .environmentObject(Settings())
            .previewColorSchemes(.dark)
    }
}
