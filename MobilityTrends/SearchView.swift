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
    @EnvironmentObject var store: Store
    
    @Binding var query: String
    
    @State private var selection = GeoType.country
    
    var body: some View {
        VStack {
            
            Picker(selection: $selection, label: Text("Geo Type")) {
                ForEach(GeoType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 12)
            .padding(.horizontal)

            HStack {
                Image(systemName: "magnifyingglass")
                    .imageScale(.small)
                    .foregroundColor(.tertiary)
                
                TextField("Search \(selection.rawValue.lowercased())…", text: $query)
                
                if query.isNotEmpty {
                    Button(action: {
                        self.query = ""
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
                .padding(.vertical, 3)
                .padding(.horizontal)
            
            List {
                ForEach(store.countries, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.query = item
                    }
                }
            }
        }
        .navigationBarTitle(Text("Search"), displayMode: .inline)
        .navigationBarItems(trailing: TrailingButtonSFSymbol("arrow.2.circlepath") {
            self.store.fetch()
        })
    }
}

struct SearchViewTesting: View {
    @State private var query = ""
    
    var body: some View {
        NavigationView {
            SearchView(query: $query)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchViewTesting()
            .environmentObject(Store())
            .environment(\.colorScheme, .dark)
    }
}
