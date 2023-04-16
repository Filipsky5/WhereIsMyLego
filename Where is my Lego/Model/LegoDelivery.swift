//
//  LegoDelivery.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 02/04/2023.
//

import Foundation

struct LegoDelivery: Codable, Hashable, Identifiable {
    var id: String
    var setNumber: Int
    var setName: String
    var deliveryDate: Date
    var distance: Int
    var imageURL: String
}
