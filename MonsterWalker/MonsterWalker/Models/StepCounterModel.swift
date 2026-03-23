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
    
    // Try and initialize the Health Store and set all the tracking variables
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            error = StepCounterError.couldNotFetchHealthStore
        }
    }
    
    //Helper to get steps from the Health Kit for any date range
    private func getSteps(from startDate: Date, to endDate: Date) async -> Double {
        guard let healthStore else { return 0 }
        
        do {
            let sampleDateRange = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            let sample = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: sampleDateRange)
            let stepsQuery = HKStatisticsQueryDescriptor(predicate: sample, options: .cumulativeSum)
            let stepsData = try await stepsQuery.result(for: healthStore)
            
            return stepsData?.sumQuantity()?.doubleValue(for: .count()) ?? 0
        } catch {
            await MainActor.run {
                self.error = error
            }
            return 0
        }
    }
    
    //Initialize the stored variables after getting permission
    private func initializeTodaysStepCounter() async {
        let stepCount = await getTodaysSteps()
    
        await MainActor.run {
            self.dailySteps = stepCount
            self.lastStepCount = stepCount
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
                let updatedSteps = await self.getTodaysSteps()
                await MainActor.run {
                    self.dailySteps = updatedSteps
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
        let currentStepCount = await getTodaysSteps()
        let newSteps = currentStepCount - lastStepCount
        
        self.dailySteps = currentStepCount
        self.lastStepCount = currentStepCount
        
        return newSteps
    }
    
    func getTodaysSteps() async -> Double {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return await getSteps(from: startOfToday, to: Date())
    }
    
    func getYesterdaySteps() async -> Double {
        let yesterdaysStartDate = Calendar.current.startOfDay(for: Date() - 1)
        let yesterdaysEndDate = Calendar.current.startOfDay(for: Date())
        return await getSteps(from: yesterdaysStartDate, to: yesterdaysEndDate)
    }
}
