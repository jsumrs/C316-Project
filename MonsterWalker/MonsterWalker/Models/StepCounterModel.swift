//
//  StepCounterModel.swift
//  MonsterWalker
//
//  Created by James Midtdal  on 2026-03-13.
//

import Foundation
import HealthKit
import Combine

enum StepCounterError: Error {
    case couldNotFetchHealthStore
}

final class StepCounterModel: ObservableObject {

    @Published var healthStore: HKHealthStore?
    @Published var error: Error?
    @Published var steps: String = "No Steps Data"
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            error = StepCounterError.couldNotFetchHealthStore
        }
    }
    
    func requestAuth() async {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let healthStore else { return }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepCountType])
        } catch {
            self.error = error
        }
    }
    
    func getTodayTotalSteps() async throws {
        guard let healthStore else { return }

        let startDate = Calendar.current.startOfDay(for: Date())
        let healthStepType = HKQuantityType(.stepCount)

        let sampleDateRange = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let sample = HKSamplePredicate.quantitySample(type: healthStepType, predicate: sampleDateRange)
        
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: sample, options: .cumulativeSum, anchorDate: startDate, intervalComponents: DateComponents(day: 1))
        
        let stepsData = try await stepsQuery.result(for: healthStore)
        
        stepsData.enumerateStatistics(from: startDate, to: Date()) { statistics, pointer in
            let stepCount = statistics.sumQuantity()?.doubleValue(for: .count())
            DispatchQueue.main.async {
                if let stepCount, stepCount > 0 {
                    self.steps = "\(Int(stepCount)) steps"
                }
            }
        }
    }
}
