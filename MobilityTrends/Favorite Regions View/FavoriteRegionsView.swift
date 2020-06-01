//
//  RegionsView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct RegionsView: View {
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @Binding var selected: String
    
    @State private var draft = ""
    @State private var showSearch = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(settings.favorites, id: \.self) { favorite in
                    HStack {
                        Text(favorite)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selected = favorite
                        self.presentation.wrappedValue.dismiss()
                    }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .navigationBarTitle(Text("Favorites"), displayMode: .inline)
            .navigationBarItems(
                leading: EditButton(),
                trailing: TrailingButtonSFSymbol("plus") {
                    self.showSearch = true
                }
                .sheet(isPresented: $showSearch, onDismiss: {
                    if self.draft.isNotEmpty {
                        self.settings.add(region: self.draft)
                    }
                }) {
                    SearchView(selection: self.$draft)
                        .environmentObject(self.store)
                        .environmentObject(self.settings)
                }
            )
        }
    }
    
    private func delete(at offsets: IndexSet) {
        settings.delete(at: offsets)
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        settings.move(from: source, to: destination)
    }
}


struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView(selected: .constant("Moscow"))
            .environmentObject(Store())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
