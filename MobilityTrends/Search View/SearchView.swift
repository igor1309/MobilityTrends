//
//  SearchView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct SearchView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @Binding var selection: String
    
    var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .imageScale(.small)
                .foregroundColor(.tertiary)
            
            TextField("Search \(store.selectedGeoType.rawValue.capitalized)", text: $store.query)
            
            if store.query.isNotEmpty {
                Button(action: {
                    self.store.query = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.tertiary)
                }
            }
        }
        .padding(6)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.tertiary, lineWidth: 0.5)
        )
    }
    
    var geoTypePicker: some View {
        Picker(selection: $store.selectedGeoType, label: Text("Geo Type")) {
            ForEach(GeoType.allCases, id: \.self) { type in
                Text(type.id).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    func regionRow(region: Region) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(region.name)
                Spacer()
            }
            if region.fullSubRegion.isNotEmpty {
                Text(region.fullSubRegion)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                searchField
                    .padding(.top, 12)
                    .padding(.horizontal)
                
                geoTypePicker
                    .padding(.vertical, 3)
                    .padding(.horizontal)
                
                List {
                    ForEach(store.queryResult) { region in
                        self.regionRow(region: region)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selection = region.name
                                self.presentation.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Select Region"), displayMode: .inline)
            .navigationBarItems(trailing: FetchDataButton().environmentObject(self.store))
        }
    }
}

struct SearchViewTesting: View {
    @State private var selection = ""
    
    var body: some View {
        SearchView(selection: $selection)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchViewTesting()
            .environmentObject(Store())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
