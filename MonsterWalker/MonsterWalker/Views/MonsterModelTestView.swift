//
//  MonsterModelTestView.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-20.
//

import SwiftUI
import SwiftData

struct MonsterModelTestView: View {

    @Environment(\.modelContext) private var context
    @Query private var monsters: [MonsterModel]
    
    // Local state to hold the resolved monster
    @State private var monsterModel: MonsterModel? = nil

    var body: some View {
        Group {
            if let monster = monsterModel {
                @Bindable var m = monster
                VStack {
                    Text("Happiness: " + String(m.happiness))
                    Text("Energy: " + String(m.energy))
                    Text("Experience.stepCount: " + String(m.experienceComponent.stepCount))
                    Text("Experience.exp: " + String(m.experienceComponent.exp))
                    Text("Experience.expCap: " + String(m.experienceComponent.expCap))
                    Text("Experience.expGainScalingFactor: " + String(m.experienceComponent.expGainScalingFactor))
                    Text("Experience.level: " + String(m.experienceComponent.level))
                    Text("Experience.streak: " + String(m.experienceComponent.streak))
                    Text("Experience.evolutionIndex: " + String(m.experienceComponent.evolutionIndex))

                    
                    
                    Spacer()
                    HStack(spacing: 150) {
                        Button("Feed",){
                            monsterModel?.feed()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Pet"){
                            monsterModel?.pet()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .onAppear {
                    monster.start()
                }
            } else {
                ProgressView() // Brief loading state
            }
        }
        .onAppear {
            if let existing = monsters.first {
                monsterModel = existing
            } else {
                let newMonster = MonsterModel(happiness: 50, energy: 100)
                context.insert(newMonster)
                monsterModel = newMonster
            }
        }
        
        
        
        
    }
}
