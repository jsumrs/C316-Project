//
//  StepCounterModel.swift
//  MonsterWalker
//
//  Created by James Midtdal on 2026-03-13.
//

import Foundation
import HealthKit
import SwiftData

enum StepCounterError: Error {
    case couldNotFetchHealthStore
}

// MARK: - SwiftData Model

@Model
final class StepCounterModel {
    
    // MARK: - Persisted Properties
    
    var stepCount: Double
    var lastCalled: Date
    
    // MARK: - Transient Properties
    
    @Transient var error: Error?
    @Transient private var healthStore: HKHealthStore?
    @Transient private var stepObserver: StepObserver?
   
    // MARK: - Init
    
    init(date: Date = .now, stepCount: Double = 0) {
        self.stepCount = stepCount
        self.lastCalled = Calendar.current.startOfDay(for: .now)
        setupHealthStore()
    }
    
    //Call this after SwiftData loads to reload the health kit
    func activate() {
        setupHealthStore()
    }
    
    private func setupHealthStore() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            error = StepCounterError.couldNotFetchHealthStore
        }
    }
    
    // MARK: - Authorization
    
    @MainActor
    func requestAuth() async {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let healthStore else { return }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepCountType])
            
            let steps = try await getTodaysSteps()
            self.stepCount = steps
            
            startObservingStepCount()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - HealthKit Queries
    
    private func getSteps(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let healthStore else {
            throw StepCounterError.couldNotFetchHealthStore
        }
        
        let sampleDateRange = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sample = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: sampleDateRange)
        let stepsQuery = HKStatisticsQueryDescriptor(predicate: sample, options: .cumulativeSum)
        let stepsData = try await stepsQuery.result(for: healthStore)
        
        return stepsData?.sumQuantity()?.doubleValue(for: .count()) ?? 0
    }
    
    func getTodaysSteps() async throws -> Double {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return try await getSteps(from: startOfToday, to: Date())
    }
    
    func getYesterdaySteps() async throws -> Double {
        let yesterdaysStartDate = Calendar.current.startOfDay(for: Date() - 1)
        let yesterdaysEndDate = Calendar.current.startOfDay(for: Date())
        return try await getSteps(from: yesterdaysStartDate, to: yesterdaysEndDate)
    }
    
    // MARK: - Step Tracking
    
    @MainActor
    func getNumberOfNewSteps() async -> Double {
        do {
            let currentStepCount = try await getTodaysSteps()
            let newSteps = try await getSteps(from: lastCalled, to: .now)
            
            self.stepCount = currentStepCount
            self.lastCalled = .now
            
            return newSteps
        } catch {
            self.error = error
            return 0
        }
    }
    
    // MARK: - HealthKit Observer
    
    @MainActor
    private func startObservingStepCount() {
        guard let healthStore else { return }
        
        let observer = StepObserver(
            healthStore: healthStore,
            onUpdate: { [weak self] steps in
                self?.stepCount = steps
            },
            onError: { [weak self] error in
                self?.error = error
            }
        )
        
        observer.start()
        self.stepObserver = observer
    }
    
    func stopObserving() {
        stepObserver?.stop()
        stepObserver = nil
    }
}
