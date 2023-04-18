//
//  BackgroundTaskService.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 18/04/2023.
//

import Foundation
import BackgroundTasks

//Nie ma pewności że aktualizacja będzie następować co 15 minut
//

final class BackgroundTasksService {
    static let shared = BackgroundTasksService()
    
    func registerBackgroundTasks() {
        let results = BGTaskScheduler.shared.register(forTaskWithIdentifier: "live.activity.updater", using: nil) { [weak self] task in
            Task {
                await LiveActivityService.shared.updateAllActivities()
                task.setTaskCompleted(success: true)
            }
            self?.scheduleNextBackgroundFetch()
        }
        
        print("Register background taks result: \(results)")
    }
    
    func submitTask() {
        scheduleNextBackgroundFetch()
    }
    
    private func scheduleNextBackgroundFetch() {
        let request = BGProcessingTaskRequest(identifier: "live.activity.updater")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3 * 60) // Schedule the next fetch in 3 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Error scheduling background task: \(error)")
        }
    }
    
}

