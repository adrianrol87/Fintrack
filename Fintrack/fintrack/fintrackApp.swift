//
//  fintrackApp.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 05/01/26.
//

import SwiftUI
import UserNotifications

@main
struct fintrackApp: App {

    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error al pedir permiso:", error)
            }
        }
    }
}

