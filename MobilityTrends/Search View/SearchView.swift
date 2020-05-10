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
    @EnvironmentObject var territories: Territories
    
    @Binding var selection: String
    
    var geoTypePicker: some View {
        Picker(selection: $territories.selectedGeoType, label: Text("Geo Type")) {
            ForEach(GeoType.allCases, id: \.self) { type in
                Text(type.id).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .imageScale(.small)
                .foregroundColor(.tertiary)
            
            TextField("Search \(territories.selectedGeoType.rawValue.capitalized)", text: $territories.query)
            
            if territories.query.isNotEmpty {
                Button(action: {
                    self.territories.query = ""
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
                    ForEach(territories.queryResult) { region in
                        HStack {
                            Text(region.name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selection = region.name
                            self.presentation.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Select Region"), displayMode: .inline)
            .navigationBarItems(trailing: TrailingButtonSFSymbol("arrow.2.circlepath") {
                self.territories.fetch()
            })
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
            .environmentObject(Territories())
            .environment(\.colorScheme, .dark)
    }
}
