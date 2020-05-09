//
//  FetchDataButton.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct FetchDataButton: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var regions: Regions
    
    var body: some View {
        Button(action: {
            self.store.fetch()
            self.regions.fetch()
        }) {
            Image(systemName: "arrow.2.circlepath")
        }
    }
}

struct FetchDataButton_Previews: PreviewProvider {
    static var previews: some View {
        FetchDataButton()
            .environmentObject(Store())
            .environmentObject(Regions())
    }
}
