//
//  StepCounterView.swift
//  MonsterWalker
//
//  Created by James Midtdal  on 2026-03-13.
//

import SwiftUI


// Jason, this is just for you to see how to check for an error from the model or get the number of steps.
// Tested on real hardware - it works. The simulator does not have HealthKit so we always get an error.
struct StepCounterView: View {
    @StateObject private var stepCounterModel = StepCounterModel()
    
    var body: some View {
        VStack {
            if let error = stepCounterModel.error {
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
                    .foregroundStyle(.red)
                
                Text(stepCounterModel.steps)
                    .font(.largeTitle)
            }
        }
        .padding()
        .task {
            await stepCounterModel.requestAuth()
            
            //How to call the function
            try? await stepCounterModel.getTodayTotalSteps()
        }
    }
}

#Preview {
    StepCounterView()
}
