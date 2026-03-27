//
//  MonsterWalkerApp.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-13.
//

import SwiftUI
import SwiftData

@main
struct MonsterWalkerApp: App {
    var body: some Scene {
        WindowGroup {
           ContentView()
        }
        .modelContainer(for: [MonsterModel.self, Experience.self, StepCounterModel.self])
        //When you set up your app with .modelContainer(for:),
        //SwiftData automatically creates a modelContext and injects it into the environment for you:
    }
}
