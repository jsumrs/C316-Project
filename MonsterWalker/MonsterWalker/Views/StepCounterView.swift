//
//  StepCounterView.swift
//  MonsterWalker
//
//  Created by James Midtdal  on 2026-03-13.
//

import SwiftUI
import SwiftData

// Step Counter Model demo.
struct StepCounterView: View {
    @Query private var stepCounters: [StepCounterModel]
    @Environment(\.modelContext) private var modelContext
    
    private var stepCounter: StepCounterModel {
        if let existing = stepCounters.first {
            return existing
        } else {
            let newCounter = StepCounterModel()
            modelContext.insert(newCounter)
            return newCounter
        }
    }
    
    @State private var newSteps: Double = 0
    
    var body: some View {
        VStack {
            //Check Health Kit reported errors
            if let error = stepCounter.error {
                ContentUnavailableView {
                    Label("No Steps Data", systemImage: "figure.walk")
                } description: {
                    Text("Error: \(String(describing: error))")
                }
            } else {
                //Published total daily steps
                Text("\(Int(stepCounter.stepCount)) steps")
                    .font(.largeTitle)
            }
            
            Text("Last checked: \(stepCounter.lastCalled)")
        }
        .padding()
        .task {
            //Get permission to use the Health Kit (shows on screen as request)
            await stepCounter.requestAuth()
        }
        Button("Steps since last call") {
            stepCounter.getNewSteps { steps in
                self.newSteps = steps
            }
        }
        Text("\(Int(newSteps)) new steps")
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    StepCounterView()
}
