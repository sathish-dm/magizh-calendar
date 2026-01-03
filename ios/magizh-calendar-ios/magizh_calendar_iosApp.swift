//
//  magizh_calendar_iosApp.swift
//  magizh-calendar-ios
//
//  Created by sathish kumar on 03/01/26.
//

import SwiftUI

@main
struct magizh_calendar_iosApp: App {
    @ObservedObject private var settings = SettingsService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settings.theme.colorScheme)
        }
    }
}
