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
    var yesterdaysSteps: Double
    var newSteps: Double
    
    // MARK: - Transient Properties
    
    @Transient var error: Error?
    @Transient private var healthStore: HKHealthStore?
   
    // MARK: - Init
    
    init() {
        self.stepCount = 0.0
        self.lastCalled = Calendar.current.startOfDay(for: .now)
        self.yesterdaysSteps = 0.0
        self.newSteps = 0.0
        setupHealthStore()
    }
    
    private func setupHealthStore() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            Task{
                await requestAuth()
            }
        } else {
            error = StepCounterError.couldNotFetchHealthStore
        }
    }
    
    // MARK: - Authorization (sole async entry point)
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
        if healthStore == nil {
            setupHealthStore()
            await requestAuth()
        }
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
    
    func getTodaysSteps(completion: ((Double) -> Void)? = nil) {
        Task { @MainActor in
            do {
                self.stepCount = try await getSteps(from: Calendar.current.startOfDay(for: .now), to: .now)
                
                completion?(self.stepCount)
            } catch {
                self.error = error
                completion?(0)
            }
        }
    }
    
    func getYesterdaysSteps(completion: ((Double) -> Void)? = nil) {
        Task { @MainActor in
            do {
                self.yesterdaysSteps = try await getSteps(
                    from: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: .now))!,
                    to: Calendar.current.startOfDay(for: .now)
                )
                
                completion?(self.yesterdaysSteps)
            } catch {
                self.error = error
                completion?(0)
            }
        }
    }
    
    func getNewSteps(completion: ((Double) -> Void)? = nil) {
        Task { @MainActor in
            do {
                // Get the total steps from the start of the day
                let currentTotalSteps = try await getSteps(from: self.lastCalled, to: .now)
                
                self.lastCalled = .now
                self.newSteps = currentTotalSteps
                
                completion?(newSteps)
            } catch {
                self.error = error
                completion?(0)
            }
        }
    }
}
