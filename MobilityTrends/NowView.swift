//
//  NowView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 22.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct NowView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @State private var showCountryDetail = false
    
    let data: [CurrentMobility.MobilityIndex]
    let max: CGFloat
    
    var sortedData: [CurrentMobility.MobilityIndex] {
        if settings.sortByName {
            return data.sorted(by: { $0.region < $1.region })
        } else {
            return data.sorted(by: { $0.value > $1.value })
        }
    }
    
    var relativeWidth: CGFloat { max == 0 ? 1 : 1 / max }
    
    let gradient = LinearGradient(gradient: Gradient(colors: [.systemBlue, .systemTeal, .green]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        
        let nameMaxLength: Int = min(self.sortedData.map { $0.region.count }.max() ?? 15, 10)
        let maxString = String(repeating: "m", count: nameMaxLength) + "100%"
        
        func bar(item: CurrentMobility.MobilityIndex) -> some View {
            let region = item.region
            let regionShort = String(item.region.prefix(13))
            
            return HStack {
                ZStack(alignment: .trailing) {
                    Text(maxString)
                        .opacity(0.001)
                        .fixedSize()
                    
                    Text("\(regionShort), \(Double(item.value).formattedPercentage)")
                }
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.leading, 6)
                
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .relativeWidth(item.normalized)
                    .fill(self.gradient)
                    .frame(height: 10)
                    .opacity(Double(item.normalized))
            }
            .contextMenu {
                Button(action: {
                    self.store.selectedRegion = region
                    self.showCountryDetail = true
                }) {
                    Image(systemName: "waveform.path.ecg")
                    
                    Text("\(item.region), \(Double(item.value).formattedPercentage)")
                }
            }
        }
        
        var grid: some View {
            HStack {
                Text(maxString)
                    .opacity(0.001)
                    .font(.caption)
                    .padding(.leading, 6)
                
                ZStack {
                    VerticalGridQuarters()
                        //  .stroke(Color.tertiary, lineWidth: 0.5)
                        //  .opacity(0.75)
                        
                        //                                VerticalGridFives()
                        .relativeWidth(relativeWidth)
                        .stroke(Color.tertiary, lineWidth: 1)
                        .opacity(0.75)
                }
            }
        }
        
        return NavigationView {
            Group {
                if sortedData.isNotEmpty {
                    VStack(spacing: 8) {
                        Text("\(store.transportType.rawValue), last week average vs mid Jan 2020")
                            .foregroundColor(.systemTeal)
                            .font(.subheadline)
                            .padding(.top, 8)
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack {
                                VStack(spacing: 2) {
                                    ForEach(sortedData) { item in
                                        bar(item: item)
                                    }
                                }
                                .padding(.bottom, 8)
                                
                                grid
                            }
                        }
                    }
                    .padding(.trailing)
                    .sheet(isPresented: $showCountryDetail) {
                        CountryTrendsView()
                            .environmentObject(self.store)
                            .environmentObject(self.settings)
                    }
                } else {
                    Text("No data, please update")
                        .padding(.top)
                        .foregroundColor(.systemRed)
                        .opacity(0.6)

                    FetchDataButton()

                    Spacer()
                }
            }
            .navigationBarTitle(Text("Current Mobility"), displayMode: .inline)
            .navigationBarItems(
                leading: indexOptionsButton,
                trailing: sortButton)
                .actionSheet(isPresented: $showIndexOptions) {
                    indexOptionsSheet()
            }
        }
    }
    
    @State private var showIndexOptions = false
    
    var indexOptionsButton: some View {
        LeadingButtonSFSymbol("wrench") {
            self.showIndexOptions = true
        }
    }
    
    func indexOptionsSheet() -> ActionSheet {
        
        func actionButtons() -> [ActionSheet.Button] {
            var buttons = [ActionSheet.Button]()
            
            for transport in [TransportType.driving, .walking] {
                buttons.append(
                    .default(Text(transport.rawValue.capitalized)) {
                        if self.store.transportType != transport {
                            self.store.transportType = transport
                        }
                    }
                )
            }
            
            buttons.append(contentsOf: [
                .destructive(Text("TBD: Mix (driving + walking)")) {
                    //  MARK: - FINISH THIS
                    print("FIX THIS")
                },
                .cancel()
            ])
            
            return buttons
        }
        
        return ActionSheet(
            title: Text("Mobility Index Options".uppercased()),
            message: Text("Select how to calculate Index"),
            buttons: actionButtons()
        )
    }
    
    var sortButton: some View {
        Button(action: {
            self.settings.sortByName.toggle()
        }) {
            Image(systemName: "textformat.size")
                .foregroundColor(settings.sortByName ? .systemOrange : .accentColor)
        }
    }
}

struct NowView_Previews: PreviewProvider {
    static let data: [CurrentMobility.MobilityIndex] = [
        CurrentMobility.MobilityIndex(region: "Moscow", value: 0.51, normalized: 0.51 / 1.25),
        CurrentMobility.MobilityIndex(region: "Rome", value: 0.75, normalized: 0.75 / 1.25),
        CurrentMobility.MobilityIndex(region: "Italy", value: 0.8, normalized: 0.8 / 1.25),
        CurrentMobility.MobilityIndex(region: "London", value: 0.6, normalized: 0.6 / 1.25),
        CurrentMobility.MobilityIndex(region: "Paris", value: 0.5, normalized: 0.5 / 1.25),
        CurrentMobility.MobilityIndex(region: "France", value: 0.15, normalized: 0.15 / 1.25),
        CurrentMobility.MobilityIndex(region: "Nice", value: 0.3, normalized: 0.3 / 1.25),
        CurrentMobility.MobilityIndex(region: "US", value: 0.4, normalized: 0.4 / 1.25),
        CurrentMobility.MobilityIndex(region: "China", value: 0.2, normalized: 0.2 / 1.25),
        CurrentMobility.MobilityIndex(region: "UK", value: 0.7, normalized: 0.7 / 1.25),
        CurrentMobility.MobilityIndex(region: "Brazil", value: 1.3, normalized: 1.3 / 1.25),
        CurrentMobility.MobilityIndex(region: "Chile", value: 0.7, normalized: 0.7 / 1.25),
        CurrentMobility.MobilityIndex(region: "Berlin", value: 1.25, normalized: 1.25 / 1.25),
        CurrentMobility.MobilityIndex(region: "Bonn", value: 0.95, normalized: 0.95 / 1.25)
    ]
    static var previews: some View {
        NowView(data: data, max: data.map { $0.value }.max()!)
            .environmentObject(Store())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
