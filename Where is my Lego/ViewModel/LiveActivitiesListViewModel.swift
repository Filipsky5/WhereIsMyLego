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
    
    func loadActivities() {
        self.deliveries = LiveActivityService.shared.loadLiveActives()
    }
    
    func removeItems(at offsets: IndexSet) {
        Task { @MainActor [weak self] in
            for index in offsets {
                guard let delivery = self?.deliveries[index] else { continue }
                await LiveActivityService.shared.endActivity(with: delivery.id)
            }
            
            self?.loadActivities()
        }
    }
}
