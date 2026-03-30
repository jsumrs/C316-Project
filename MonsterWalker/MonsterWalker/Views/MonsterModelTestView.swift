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
    
    @State private var monsterModel: MonsterModel? = nil

    var body: some View {
        Group {
            if let monster = monsterModel {
                @Bindable var m = monster
                VStack(alignment: .leading) {
                    StatRowView(label: "Happiness", value: $m.happiness)
                    StatRowView(label: "Energy", value: $m.energy)
                    StatRowView(label: "expGainScalingFactor", value: $m.experienceComponent.expGainScalingFactor, step: 0.1)
                    StatRowInt64View(label: "stepCount", value: $m.experienceComponent.stepCount, step: 100)
                    StatRowInt64View(label: "exp", value: $m.experienceComponent.exp, step: 100)
                    StatRowInt64View(label: "expCap", value: $m.experienceComponent.expCap)
                    StatRowIntView(label: "level", value: $m.experienceComponent.level, step: 1)
                    StatRowIntView(label: "streak", value: $m.experienceComponent.streak, step: 1)
                    StatRowIntView(label: "evolutionIndex", value: $m.experienceComponent.evolutionIndex, step: 1)
                    Spacer()
                    HStack(alignment: .center) {
                        Button("Feed") {
                            monsterModel?.feed()
                        }
                        Button("Pet") {
                            monsterModel?.pet()
                        }
                    } .buttonStyle(CustomButtonStyle())

                } .onAppear {
                    Task {
                        await monster.start()
                    }
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


// MARK: - StatRow Buttons
struct StatRowView: View {
    let label: String
    @Binding var value: Double
    let step: Double
    
    init(label: String, value: Binding<Double>, step: Double = 10) {
        self.label = label
        self._value = value
        self.step = step
    }
    
    var body: some View {
        HStack {
            Text("\(label): \(value, specifier: "%.2f")")
            Button("-\(step, specifier: "%.2f")") { value = max(0, value - step) }
            Button("+\(step, specifier: "%.2f")") { value += step }
        }
    }
}

struct StatRowIntView: View {
    let label: String
    @Binding var value: Int
    let step: Int
    
    init(label: String, value: Binding<Int>, step: Int = 10) {
        self.label = label
        self._value = value
        self.step = step
    }
    
    var body: some View {
        HStack {
            Text("\(label): \(value)")
            Button("-\(step)") { value = max(0, value - step) }
            Button("+\(step)") { value += step }
        }
    }
}

struct StatRowInt64View: View {
    let label: String
    @Binding var value: Int64
    let step: Int64
    
    init(label: String, value: Binding<Int64>, step: Int64 = 10) {
        self.label = label
        self._value = value
        self.step = step
    }
    
    var body: some View {
        HStack {
            Text("\(label): \(value)")
            Button("-\(step)") { value = max(0, value - step) }
            Button("+\(step)") { value += step }
        }
    }
}

#Preview {
    MonsterModelTestView()
}
