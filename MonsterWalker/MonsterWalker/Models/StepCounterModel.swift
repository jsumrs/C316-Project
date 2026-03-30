import Foundation
import HealthKit
import SwiftData

enum StepCounterError: Error {
    case couldNotFetchHealthStore
}

@Model
final class StepCounterModel {
    
    // MARK: - Persisted Properties
    
    var stepCount: Double
    var lastCalled: Date
    
    // MARK: - Transient Properties
    
    @Transient var error: Error?
    @Transient private var healthStore: HKHealthStore?
   
    // MARK: - Init
    
    init(date: Date = .now, stepCount: Double = 0) {
        self.stepCount = stepCount
        self.lastCalled = Calendar.current.startOfDay(for: .now)
        setupHealthStore()
    }
    
    private func setupHealthStore() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            error = StepCounterError.couldNotFetchHealthStore
        }
    }
    
    // MARK: - Authorization (sole async entry point)
    @MainActor
    func requestAuth() async {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let healthStore else { return }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepCountType])
            let steps = try await getSteps(from: Calendar.current.startOfDay(for: .now), to: .now)
            self.stepCount = steps
        } catch {
            self.error = error
        }
    }
    
    // MARK: - HealthKit Query (private async helper)
    
    @MainActor
    private func getSteps(from startDate: Date, to endDate: Date) async throws -> Double {
        if healthStore == nil { setupHealthStore() }
        guard let healthStore else {
            throw StepCounterError.couldNotFetchHealthStore
        }
        
        let sampleDateRange = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sample = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: sampleDateRange)
        let stepsQuery = HKStatisticsQueryDescriptor(predicate: sample, options: .cumulativeSum)
        let stepsData = try await stepsQuery.result(for: healthStore)
        
        return stepsData?.sumQuantity()?.doubleValue(for: .count()) ?? 0
    }
    
    // MARK: - Timer-callable (sync interface, async internals)
    
    func getTodaysSteps() {
        Task { @MainActor in
            do {
                self.stepCount = try await getSteps(from: Calendar.current.startOfDay(for: .now), to: .now)
            } catch {
                self.error = error
            }
        }
    }
    
    func getNewSteps(completion: ((Double) -> Void)? = nil) {
        Task { @MainActor in
            do {
                let currentStepCount = try await getSteps(from: Calendar.current.startOfDay(for: .now), to: .now)
                let newSteps = currentStepCount - self.stepCount
                
                self.stepCount = currentStepCount
                self.lastCalled = .now
                
                completion?(newSteps)
            } catch {
                self.error = error
                completion?(0)
            }
        }
    }
}
