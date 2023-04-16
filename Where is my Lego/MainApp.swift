//
//  Where_is_my_LegoApp.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 02/04/2023.
//

import SwiftUI

@main
struct MainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            LiveActivitiesList(viewModel:LiveActivitiesListViewModel())
        }
    }
}
