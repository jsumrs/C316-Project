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
    @Environment(\.scenePhase) private var scenePhase
    
    // Create the model container once and reuse it
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: MonsterModel.self, Experience.self, StepCounterModel.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
           ContentView()
                .background(Theme.background.ignoresSafeArea())
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background:
                // Save all changes when app goes to background
                saveContext()
            case .inactive:
                // Also save when app becomes inactive (user might be closing)
                saveContext()
            case .active:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func saveContext() {
        let context = modelContainer.mainContext
        
        // Only save if there are actual changes
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully")
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
