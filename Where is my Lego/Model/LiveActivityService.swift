//
//  LiveActivityService.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 17/04/2023.
//

import UIKit
import ActivityKit

enum ActivityError: Error {
    case activityNotEnabled
    case invalidURL
    case missingActivity
}

final class LiveActivityService {
    static let shared = LiveActivityService()
    private let fiveMinutes: TimeInterval = 5 * 60
    
    func addActivity(legoDelivery: LegoDelivery) async throws -> String {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw ActivityError.activityNotEnabled
        }
        guard let url = URL(string: legoDelivery.imageURL) else {
            throw ActivityError.invalidURL
        }
        let imageURL = try await downloadImage(from: url)
        let attributes = LiveActivityAttributes(imageURL: legoDelivery.imageURL, setName: legoDelivery.setName, setNumber: legoDelivery.setNumber, imageName: imageURL?.lastPathComponent)
        let contentState = LiveActivityAttributes.ContentState(deliveryTime: formatTimeDiffFromNow(date: legoDelivery.deliveryDate), distance: legoDelivery.distance, deliveryDate: legoDelivery.deliveryDate)
        let content = ActivityContent<LiveActivityAttributes.ContentState>(state: contentState, staleDate: Date.now.addingTimeInterval(fiveMinutes))
        let activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
        return activity.id
    }
    
    func updateLiveActivity(legoDelivery: LegoDelivery) async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw ActivityError.activityNotEnabled
        }
        guard let liveActivity = Activity<LiveActivityAttributes>.activities.first(where: { $0.id == legoDelivery.id }) else {
            throw ActivityError.missingActivity
        }
        let contentState = LiveActivityAttributes.ContentState(deliveryTime: formatTimeDiffFromNow(date: legoDelivery.deliveryDate), distance: legoDelivery.distance, deliveryDate: legoDelivery.deliveryDate)
        let newState = ActivityContent<Activity<LiveActivityAttributes>.ContentState>.init(state: contentState, staleDate: Date().addingTimeInterval(fiveMinutes), relevanceScore: liveActivity.content.relevanceScore)
        
        await liveActivity.update(newState)
    }
    
    func endActivity(with id: String) async {
        let liveActivity = Activity<LiveActivityAttributes>.activities.first(where: { $0.id == id })
        await liveActivity?.end(nil, dismissalPolicy: .immediate)
    }
    
    func loadLiveActives() -> [LegoDelivery] {
        let liveActivates = Activity<LiveActivityAttributes>.activities.compactMap { LegoDelivery(id: $0.id, setNumber: $0.attributes.setNumber, setName: $0.attributes.setName, deliveryDate: $0.content.state.deliveryDate, distance: $0.content.state.distance, imageURL: $0.attributes.imageURL) }
        return liveActivates
    }
    
    func updateAllActivities() async {
        let liveActivates = Activity<LiveActivityAttributes>.activities
        let numberOfActivities = liveActivates.count
        let tenMinutes:TimeInterval = 10 * 60
        for (index, activity) in liveActivates.enumerated() {
            var deliveryTime: String
            var distance: Int
            var deliveryDate: Date
            switch activity.content.state.distance {
            case 0..<1000:
                distance = 0
                deliveryTime = "Soon"
                deliveryDate = Date.now
            case 1000..<5000:
                distance = 500
                deliveryTime = "5 min"
                deliveryDate = Date.now.addingTimeInterval(fiveMinutes)
            default:
                distance = 2000
                deliveryTime = "10 min"
                deliveryDate = Date.now.addingTimeInterval(tenMinutes)
            }
            let relevanceScore = Double(100 / numberOfActivities * (index + 1))
            let contentState = LiveActivityAttributes.ContentState(deliveryTime: deliveryTime, distance: distance, deliveryDate: deliveryDate)
            let newState = ActivityContent<Activity<LiveActivityAttributes>.ContentState>.init(state: contentState, staleDate: Date.now.addingTimeInterval(fiveMinutes), relevanceScore: relevanceScore)
            
            await activity.update(newState)
        }
    }
}

extension LiveActivityService {
    
    private func formatTimeDiffFromNow(date: Date) -> String {
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: Date.now, to: date)
        var dateStrings:[String] = []
        if let hours = diffComponents.hour {
            dateStrings.append("\(hours)h")
        }
        if let minutes = diffComponents.minute {
            dateStrings.append("\(minutes)m")
        }
        return dateStrings.joined(separator: " ")
    }
    
    private func downloadImage(from url: URL) async throws -> URL? {
        guard var destination = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.filip.jablonski.practi.Where-is-my-Lego")
        else { return nil }
        
        destination = destination.appendingPathComponent(url.lastPathComponent)
        
        guard !FileManager.default.fileExists(atPath: destination.path()) else {
            print("No need to download \(url.lastPathComponent) as it already exists.")
            return destination
        }
        
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let image = UIImage(data: data)!
        //Live activity has a limitation in image size (max 320x320)
        //https://developer.apple.com/forums/thread/716902
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 90, height: 90))
        let resizedImage = renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: CGSize(width: 90, height: 90)))
        }
        if let data = resizedImage.pngData() {
            try data.write(to: destination)
        }
        return destination
    }
}
