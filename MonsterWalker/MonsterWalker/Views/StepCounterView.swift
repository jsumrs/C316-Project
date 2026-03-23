//
//  StepCounterView.swift
//  MonsterWalker
//
//  Created by James Midtdal  on 2026-03-13.
//

import SwiftUI

// Step Counter Model demo.
struct StepCounterView: View {
    @StateObject private var stepCounter = StepCounterModel()
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
                Image(systemName: "figure.walk")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundStyle(.green)
                
                //Published total daily steps
                Text("\(Int(stepCounter.dailySteps)) steps")
                    .font(.largeTitle)
            }
        }
        .padding()
        .task {
            //Get permission to use the Health Kit (shows on screen as request)
            await stepCounter.requestAuth()
        }
        Button("Steps since last call") {
            Task {
                newSteps = await stepCounter.getNumberOfNewSteps()
            }
        }.padding()
        Text("\(Int(newSteps)) new steps")
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    StepCounterView()
}
