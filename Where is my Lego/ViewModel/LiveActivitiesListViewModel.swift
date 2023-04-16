//
//  LiveActivitiesListViewModel.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 16/04/2023.
//

import Foundation

final class LiveActivitiesListViewModel: ObservableObject {
    
    @Published var deliveries: [LegoDelivery] = []
    
    init() {
        loadActivities()
    }
    
    func loadActivities() {}
    
    func removeItems(at offsets: IndexSet) {
        Task { @MainActor [weak self] in
            self?.loadActivities()
        }
    }
}
