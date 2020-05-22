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
    
    var updateButton: some View {
        Button(action: {
            self.store.fetch(version: self.settings.version)
        }) {
            Image(systemName: store.updateStatus.icon)
                .foregroundColor(store.updateStatus.color)
                .rotationEffect(.degrees(store.updateStatus.isUpdating ? 180 : 0))
                .animation(store.updateStatus.isUpdating ? Animation.linear.repeatForever(autoreverses: false) : .default)
        }
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
            .navigationBarItems(trailing: updateButton.padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 0)))
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
