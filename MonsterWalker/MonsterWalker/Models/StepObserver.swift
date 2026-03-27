//
//  StepObserver.swift
//  MonsterWalker
//
//  Created by James Midtdal  on 2026-03-27.
//

import HealthKit

// MARK: - HealthKit Observer Helper

// A Sendable helper that owns the HKObserverQuery and forwards updates back to the MainActor via a callback. This avoids capturing the non-Sendable @Model in a @Sendable closure.
final class StepObserver: Sendable {
    
    private let healthStore: HKHealthStore
    private let onUpdate: @MainActor @Sendable (Double) -> Void
    private let onError: @MainActor @Sendable (Error) -> Void
    
    // Store it so we can release it properly on destruction
    let query: HKObserverQuery
    
    init(
        healthStore: HKHealthStore,
        onUpdate: @MainActor @Sendable @escaping (Double) -> Void,
        onError: @MainActor @Sendable @escaping (Error) -> Void
    ) {
        self.healthStore = healthStore
        self.onUpdate = onUpdate
        self.onError = onError
        
        self.query = HKObserverQuery(
            sampleType: HKQuantityType(.stepCount),
            predicate: nil
        ) { _, completionHandler, error in
            if let healthKitError = error {
                Task { @MainActor in
                    onError(healthKitError)
                }
                completionHandler()
                return
            }
            
            Task {
                do {
                    let startOfToday = Calendar.current.startOfDay(for: Date())
                    let sampleDateRange = HKQuery.predicateForSamples(withStart: startOfToday, end: Date())
                    let sample = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: sampleDateRange)
                    let stepsQuery = HKStatisticsQueryDescriptor(predicate: sample, options: .cumulativeSum)
                    let stepsData = try await stepsQuery.result(for: healthStore)
                    let steps = stepsData?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    
                    await MainActor.run {
                        onUpdate(steps)
                    }
                } catch {
                    // Leave last known value — HealthKit throws when phone is locked
                }
                completionHandler()
            }
        }
    }
    
    func start() {
        healthStore.execute(query)
        
        healthStore.enableBackgroundDelivery(
            for: HKQuantityType(.stepCount),
            frequency: .immediate
        ) { _, error in
            if let healthKitError = error {
                Task { @MainActor in
                    self.onError(healthKitError)
                }
            }
        }
    }
    
    func stop() {
        healthStore.stop(query)
    }
}
