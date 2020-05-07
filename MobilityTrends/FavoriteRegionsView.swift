//
//  FavoriteRegionsView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct FavoriteRegionsView: View {
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var store: Store
    
    @EnvironmentObject var favoriteRegions: FavoriteRegions
    
    @Binding var selected: String
    
    @State private var draft = ""
    @State private var showSearch = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favoriteRegions.regions, id: \.self) { region in
                    HStack {
                        Text(region)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selected = region
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
                        self.favoriteRegions.add(region: self.draft)
                    }
                }) {
                    //  MARK: THAT'S NOT COREECT!!!!!
                    SearchView(selection: self.$draft)
                        .environmentObject(self.store)
                }
            )
        }
    }
    
    private func delete(at offsets: IndexSet) {
        favoriteRegions.delete(at: offsets)
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        favoriteRegions.move(from: source, to: destination)
    }
}


struct FavoriteRegionsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteRegionsView(selected: .constant("Moscow"))
            .environment(\.colorScheme, .dark)
    }
}
