//
//  DevControlView.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-20.
//

import SwiftUI
import SwiftData

struct DevControlView: View {
    @Environment(\.modelContext) private var context
    @Query private var monsters: [MonsterModel]
    @State private var monsterModel: MonsterModel? = nil
    
    var body: some View {
        Group {
            if let monster = monsterModel {
                DevControlLoadedView(monster: monster)
            } else {
                ProgressView() // Loading state
            }
        }
        .onAppear {
            if let existing = monsters.first {
                monsterModel = existing
            } else {
                let newMonster = MonsterModel(happiness: 50, energy: 100)
                context.insert(newMonster)
                monsterModel = newMonster
                do {
                    try context.save() // Explicit save to ensure persistence.
                } catch {
                    print("Failed to save new monster: \(error)")
                }
            }
        }
    }
}







#Preview {
    DevControlView()
}
