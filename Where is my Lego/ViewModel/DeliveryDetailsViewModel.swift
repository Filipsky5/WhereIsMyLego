//
//  DeliveryDetailsViewModel.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 02/04/2023.
//

import Foundation
import UserNotifications
import UIKit

enum ValidationError: Error {
    case invalidDistance
    case invalidSetNumber
}

final class DeliveryDetailsViewModel: ObservableObject {
    
    var setNumber: String
    var setName: String
    var deliveryDate: Date
    var distance: String
    var imageURL: String
    
    var navigationTitle: String = ""
    var actionButtonTitle: String = ""
    
    @MainActor @Published var token: String = ""
    @MainActor @Published var isLoading = false
    @Published var editMode: Bool = true
    @Published var isTokenEnabled = false
    
    private var legoDelivery: LegoDelivery
    
    @MainActor
    init(legoDelivery: LegoDelivery? = nil) {
        if let legoDelivery {
            self.legoDelivery = legoDelivery
            setNumber = String(legoDelivery.setNumber)
            setName = legoDelivery.setName
            deliveryDate = legoDelivery.deliveryDate
            distance = String(legoDelivery.distance)
            imageURL = legoDelivery.imageURL
            configureMode(isEditMode: true)
            
        } else {
            self.legoDelivery = LegoDelivery(id: UUID().uuidString, setNumber: 1234, setName: "Batmobile", deliveryDate: Date(timeIntervalSinceNow: 3600), distance: 2000, imageURL: "https://www.lego.com/cdn/cs/set/assets/blt755a6d05eac6630d/76240.png")
            setNumber = String(self.legoDelivery.setNumber)
            setName = self.legoDelivery.setName
            deliveryDate = self.legoDelivery.deliveryDate
            distance = String(self.legoDelivery.distance)
            imageURL = self.legoDelivery.imageURL
            configureMode(isEditMode: false)
        }
        token = LiveActivityService.shared.getToken(for: self.legoDelivery.id) ?? ""
    }
    
    func configureMode(isEditMode: Bool) {
        if isEditMode {
            navigationTitle = "Edit Set"
            actionButtonTitle = "Save"
            editMode = true
            Task {
               await startObservingTokenChange(forId: legoDelivery.id)
            }
        } else {
            navigationTitle = "Add Set"
            actionButtonTitle = "Add"
            editMode = false
        }
    }
    
    @MainActor
    private func startObservingTokenChange(forId activityId: String) async {
        guard let asyncTokenIterator = LiveActivityService.shared.startObservingTokenChanges(for: activityId) else { return }
        for await newToken in asyncTokenIterator {
            token = newToken
            isTokenEnabled = true
        }
    }
    
    private func validateAndUpdate() throws {
        guard let mappedDistance = Int(distance) else {
            throw ValidationError.invalidDistance
        }
        
        guard let mappedSetNumber = Int(setNumber) else {
            throw ValidationError.invalidSetNumber
        }
        legoDelivery.setName = setName
        legoDelivery.setNumber = mappedSetNumber
        legoDelivery.deliveryDate = deliveryDate
        legoDelivery.distance = mappedDistance
        legoDelivery.imageURL = imageURL
    }
    
    func saveOrAdd() {
        Task { @MainActor in
            isLoading = true
            do {
                try validateAndUpdate()
                try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                UIApplication.shared.registerForRemoteNotifications()
                
                if editMode {
                   //TODO: Handle Editing
                    try await LiveActivityService.shared.updateLiveActivity(legoDelivery: legoDelivery)
                } else {
                    //TODO: Creation
                    legoDelivery.id = try await LiveActivityService.shared.addActivity(legoDelivery: legoDelivery, isTokenEnabled: isTokenEnabled)
                    configureMode(isEditMode: true)
                }
            } catch let error {
                print(error.localizedDescription)
            }
            isLoading = false
        }
    }
}
