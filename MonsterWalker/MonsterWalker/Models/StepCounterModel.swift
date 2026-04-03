import Foundation
import HealthKit
import SwiftData

enum StepCounterError: Error {
    case healthDataNotAvailable
    case healthStoreNotInitialized
}

// MARK: Health Kit

actor HealthKitService {
    static let shared = HealthKitService()
    
    private var healthStore: HKHealthStore?
    private var isAuthorized = false

    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        }
    }

    var isAvailable: Bool { healthStore != nil }

    func requestAuthorization() async throws {
        guard !isAuthorized else { return }
        guard let healthStore else {
            throw StepCounterError.healthStoreNotInitialized
        }
        let stepCountType = HKQuantityType(.stepCount)
        try await healthStore.requestAuthorization(toShare: [], read: [stepCountType])
        isAuthorized = true
    }

    func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let healthStore else {
            throw StepCounterError.healthStoreNotInitialized
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sample = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.stepCount),
            predicate: predicate
        )
        let query = HKStatisticsQueryDescriptor(predicate: sample, options: .cumulativeSum)
        let result = try await query.result(for: healthStore)
        return result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
    }
}

// MARK: - StepCounterModel
@MainActor
@Model
final class StepCounterModel {

    // MARK: - Persisted Properties

    var stepCount: Double
    var previousTotal: Double
    var lastTrackedDay: Date
    var yesterdaysSteps: Double
    var newSteps: Double

    // MARK: - Transient Properties

    @Transient var error: Error?

    // MARK: - Init

    init() {
        self.stepCount = 0.0
        self.previousTotal = 0.0
        self.lastTrackedDay = Calendar.current.startOfDay(for: .now)
        self.yesterdaysSteps = 0.0
        self.newSteps = 0.0
    }

    func setup() async {
        let service = HealthKitService.shared
        guard await service.isAvailable else {
            self.error = StepCounterError.healthDataNotAvailable
            return
        }

        do {
            try await service.requestAuthorization()
        } catch {
            self.error = error
        }
    }

    // MARK: - Public API

    func getTodaysSteps() async -> Double {
        do {
            let service = HealthKitService.shared
            let steps = try await service.fetchSteps(
                from: Calendar.current.startOfDay(for: .now),
                to: .now
            )
            self.stepCount = steps
            return steps
        } catch {
            self.error = error
            return 0
        }
    }

    func getYesterdaysSteps() async -> Double {
        do {
            let service = HealthKitService.shared
            let startOfToday = Calendar.current.startOfDay(for: .now)
            let startOfYesterday = Calendar.current.date(
                byAdding: .day, value: -1, to: startOfToday
            )!
            let steps = try await service.fetchSteps(
                from: startOfYesterday,
                to: startOfToday
            )
            self.yesterdaysSteps = steps
            return steps
        } catch {
            self.error = error
            return 0
        }
    }

    func getNewSteps() async -> Double {
        do {
            let service = HealthKitService.shared
            let startOfToday = Calendar.current.startOfDay(for: .now)

            // Day rolled over — reset baseline
            if startOfToday != lastTrackedDay {
                previousTotal = 0
                lastTrackedDay = startOfToday
            }

            let currentTotal = try await service.fetchSteps(
                from: startOfToday,
                to: .now
            )

            let delta = max(currentTotal - previousTotal, 0)
            if delta > 0 {
                previousTotal = currentTotal
            }

            self.newSteps = delta
            return delta
        } catch {
            print("[StepCounter] getNewSteps FAILED: \(error)")
            self.error = error
            return 0
        }
    }
}
