//
//  SettingsView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 21.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Version".uppercased()),
                        footer: Text("Apple Mobility Trends Version. Be careful with change. Ping to test.")
                ) {
                    Stepper("Version #\(settings.version)", value: $settings.version)
                    
                    if settings.pingResult.isNotEmpty {
                        Text(settings.pingResult)
                            .foregroundColor(settings.pingResultColor)
                    }
                    
                    Button("Ping") {
                        self.settings.ping(version: self.settings.version)
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Store())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
