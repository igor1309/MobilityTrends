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
    
    @Binding var selection: String
    
    var geoTypePicker: some View {
        Picker(selection: $store.selectedGeoType, label: Text("Geo Type")) {
            ForEach(GeoType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
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
                        .foregroundColor(.accentColor)
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
                    ForEach(store.queryList, id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selection = item
                            self.presentation.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Select Region"), displayMode: .inline)
            .navigationBarItems(trailing: TrailingButtonSFSymbol("arrow.2.circlepath") {
                self.store.fetch()
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
            .environmentObject(Store())
            .environment(\.colorScheme, .dark)
    }
}
