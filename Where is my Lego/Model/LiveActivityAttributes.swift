//
//  LiveActivityAttributes.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 16/04/2023.
//

import Foundation
import ActivityKit
import UIKit

struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var deliveryTime: String
        var distance: Int
        
        var distanceValue: Double {
            switch distance {
            case 0:
                return 1
            case 1...1000:
                return 0.66
            case 1000...5000:
                return 0.33
            default:
                return 0
            }
        }
    }
    
    // Fixed non-changing properties about your activity go here!
    var imageURL: String
    var setName: String
    var setNumber: Int
    
    
    var imageName: String?
    var image: UIImage? {
        guard let imageName, let imageContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.filip.jablonski.practi.Where-is-my-Lego")?
            .appendingPathComponent(imageName) else { return nil }
        return UIImage(contentsOfFile: imageContainer.path())
    }
    
}

