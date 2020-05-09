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
    @EnvironmentObject var regions: Regions
    
    @Binding var selected: String
    
    @State private var draft = ""
    @State private var showSearch = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(regions.favorites, id: \.self) { favorite in
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
            .navigationBarTitle("Favorites")
            .navigationBarItems(
                leading: EditButton(),
                trailing: TrailingButtonSFSymbol("plus") {
                    //  MARK: FINISH THIS
                    //
                    self.showSearch = true
                }
                .sheet(isPresented: $showSearch, onDismiss: {
                    if self.draft.isNotEmpty {
                        self.regions.add(region: self.draft)
                    }
                }) {
                    //  MARK: THAT'S NOT COREECT!!!!!
                    SearchView(selection: self.$draft)
                        .environmentObject(self.store)
                        .environmentObject(self.regions)
                }
            )
        }
    }
    
    private func delete(at offsets: IndexSet) {
        regions.delete(at: offsets)
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        regions.move(from: source, to: destination)
    }
}


struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView(selected: .constant("Moscow"))
            .environmentObject(Store())
            .environmentObject(Regions())
            .environment(\.colorScheme, .dark)
    }
}
