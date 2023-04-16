//
//  DeliveryDetailsViewModel.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 02/04/2023.
//

import Foundation

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
    }
    
    func configureMode(isEditMode: Bool) {
        if isEditMode {
            navigationTitle = "Edit Set"
            actionButtonTitle = "Save"
            editMode = true
        } else {
            navigationTitle = "Add Set"
            actionButtonTitle = "Add"
            editMode = false
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
                if editMode {
                   //TODO: Handle Editing
                } else {
                    //TODO: Creation
                    configureMode(isEditMode: true)
                }
            } catch let error {
                print(error.localizedDescription)
            }
            isLoading = false
        }
    }
}
