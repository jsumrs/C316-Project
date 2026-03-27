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

    @Published var error: Error?
    @Published var dailySteps: Double = 0
    
    private var lastStepCount: Double = 0
    private var healthStore: HKHealthStore?
    private var observerQuery: HKObserverQuery?
    private var lastGetNewStepsDate: Date = Calendar.current.startOfDay(for: Date.now)
    
    // Try and initialize the Health Store and set all the tracking variables
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            lastGetNewStepsDate = Calendar.current.startOfDay(for: Date.now)
        } else {
            error = StepCounterError.couldNotFetchHealthStore
        }
    }
    
    //Helper to get steps from the Health Kit for any date range
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
    
    //Initialize the stored variables after getting permission
    private func initializeTodaysStepCounter() async {
        do {
            let stepCount = try await getTodaysSteps()
        
            await MainActor.run {
                self.dailySteps = stepCount
                self.lastStepCount = stepCount
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    // Get permission to use the Health Kit from the user
    @MainActor
    func requestAuth() async {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let healthStore else { return }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepCountType])
            
            await initializeTodaysStepCounter()

            startObservingStepCount()
        } catch {
            self.error = error
        }
    }
    
    // Use HealthKit observer for real-time updates from the HK
    private func startObservingStepCount() {
        guard let healthStore else { return }
        
        // Create an observer query that will be called whenever step count data changes
        let query = HKObserverQuery(sampleType: HKQuantityType(.stepCount), predicate: nil) { [weak self] _, completionHandler, error in
            guard let self = self else {
                completionHandler()
                return
            }
            
            //Grab any Health Kit errors
            if let healthKitError = error {
                Task { @MainActor in
                    self.error = healthKitError
                }
                completionHandler()
                return
            }
            
            // Fetch the updated step count
            Task {
                do {
                    let updatedSteps = try await self.getTodaysSteps()
                    await MainActor.run {
                        self.dailySteps = updatedSteps
                    }
                } catch {
                    // Don't update dailySteps — just leave the last known value. The observer querying the health kit while the phone is locked
                    // will throw an error and crash, so its best to just catch and move on, and retry later.
                }
                completionHandler()
            }
        }
        
        //Register observer query with the health kit
        healthStore.execute(query)
        
        //Stash it for proper cleanup on model destruction
        self.observerQuery = query
        
        // Enable background delivery for step count updates
        healthStore.enableBackgroundDelivery(for: HKQuantityType(.stepCount), frequency: .immediate) { success, error in
            if let healthKitError = error {
                Task { @MainActor in
                    self.error = healthKitError
                }
            }
        }
    }
    
    // Clean up the observer when the model is deallocated
    deinit {
        if let observerQuery = observerQuery, let healthStore = healthStore {
            healthStore.stop(observerQuery)
        }
    }

    // Returns the number of steps taken since the last time this function was called
    @MainActor
    func getNumberOfNewSteps() async -> Double {
        do {
            let currentStepCount = try await getTodaysSteps()
            let newSteps = try await getSteps(from: lastGetNewStepsDate, to: Date.now)
            
            self.dailySteps = currentStepCount
            self.lastStepCount = currentStepCount
            self.lastGetNewStepsDate = Date.now
            
            return newSteps
        } catch {
            self.error = error
            return 0
        }
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
}
