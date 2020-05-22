//
//  Settings.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 21.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class Settings: ObservableObject {
    private let mobilityTrendsAPI: MobilityTrendsAPI
    
    @Published var selectedTab: Int = UserDefaults.standard.integer(forKey: "selectedTab") {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: "selectedTab")
        }
    }
    
    @Published var version: Int = UserDefaults.standard.integer(forKey: "AppleMobilityVersion") {
        didSet {
            UserDefaults.standard.set(version, forKey: "AppleMobilityVersion")
        }
    }
    
    @Published var pingResult: String = ""
    
    private var pingRequested = PassthroughSubject<Int, Never>()
    
    init(api: MobilityTrendsAPI = .shared) {
        self.mobilityTrendsAPI = api
        
        //  create subscriptions
        self.createPingSubscription()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}

extension Settings {
    
    func ping(version: Int) {
        pingRequested.send(version)
    }
    
    func createPingSubscription() {
        pingRequested
            .flatMap { self.mobilityTrendsAPI.ping(version: $0) }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.pingResult = $0
        }
        .store(in: &cancellables)
    }
    
    var pingResultColor: Color {
        if pingResult.lowercased().contains("error") {
            return .systemRed
        } else {
            return .systemGreen
        }
    }
}
