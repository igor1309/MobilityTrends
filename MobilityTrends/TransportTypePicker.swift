//
//  TransportTypePicker.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 07.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct TransportTypePicker: View {
    @Binding var selection: TransportType
    
    var body: some View {
        Picker("Transportation Type", selection: $selection) {
            ForEach(TransportType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct TransportTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        TransportTypePicker(selection: .constant(.driving))
    }
}
