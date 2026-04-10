import Combine
import Foundation
import UIKit
import SwiftData
import SwiftUI

@MainActor
@Model
class Experience {

    // MARK: - Persisted Properties
    public var exp: Int64
    public var expCap: Int64
    public var expGainScalingFactor: Double
    public var level: Int
    public var evolutionLevels: [Int]
    public var evolutionIndex: Int

    var newSteps: Int
    var stepCount: Int64
    var streak: Int
    var lastStreakDate: Date
    @Relationship(deleteRule: .cascade) var stepCounter: StepCounterModel

    // MARK: - Transient (runtime-only) Properties
    @Transient var streakTimer: Timer? = nil
    @Transient var happiness: Double = 0.0
    @Transient var energy: Double = 0.0
    @Transient var audio = AudioPlayerModel()

    init(happiness: Double = 0.0, energy: Double = 0.0) {
        lastStreakDate = Date()
        streak = 0
        exp = 0
        expCap = 1000
        expGainScalingFactor = 1.0
        stepCount = 0
        level = 0
//        evolutionLevels = [0, 5, 20, 50, 70, 100]
        evolutionLevels = [0, 1, 2, 3, 4, 5]
        evolutionIndex = 0
        newSteps = 0
        self.happiness = happiness
        self.energy = energy
        stepCounter = StepCounterModel()
    }

    func start() async {
        guard streakTimer == nil else { return }
        await stepCounter.setup()
        setupStreakTimer()
        await checkStreakOnLaunch()
    }
    
    func getStepsToNextLevel() -> Int{
        return Int(ceil(Double((expCap - exp)) / expGainScalingFactor))
    }

    // MARK: - Streak Timer

    private func setupStreakTimer() {
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        guard let targetTime = Calendar.current.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime
        ) else { return }

        let t = Timer(fire: targetTime, interval: 0, repeats: false) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.streakTimerEvent()
            }
        }
        streakTimer = t
        RunLoop.main.add(t, forMode: .common)
    }

    // MARK: - Streak Logic

    private func checkStreakOnLaunch() async {
        let calendar = Calendar.current
        let now = Date()

        guard !calendar.isDateInToday(lastStreakDate) else { return }

        if calendar.isDateInYesterday(lastStreakDate) {
            let steps = await stepCounter.getYesterdaysSteps()
            if steps >= 5000 && energy > 0 {
                streak += 1
            } else {
                streak = 0
            }
        } else {
            streak = 0
        }

        lastStreakDate = now
        changeExpScalingFactor()
    }

    private func streakTimerEvent() async {
        let tempDate = Date()

        let todaysSteps = await stepCounter.getTodaysSteps()

        if todaysSteps >= 5000 && energy > 0 {
            streak += 1
        } else {
            streak = 0
        }
        lastStreakDate = tempDate
        changeExpScalingFactor()
        setupStreakTimer()
    }

    // MARK: - Experience Scaling

    func changeExpScalingFactor() {
        if energy <= 0 {
            streak = 0
        }

        var baseScalingFactor: Double = 1.0
        baseScalingFactor += Double(streak) * 0.5
        baseScalingFactor = min(baseScalingFactor, 5.0)

        if happiness == 0 {
            baseScalingFactor /= 2
        }
        expGainScalingFactor = baseScalingFactor
    }

    // MARK: - Leveling

    private func levelUp() {
        audio.playSound(.levelUp)
        level += 1
        let expCapScalingFactor: Double = 1.15
        expCap = Int64(Double(expCap) * expCapScalingFactor)

        if evolutionIndex + 1 < evolutionLevels.count &&
           level >= evolutionLevels[evolutionIndex + 1] {
            evolutionIndex += 1
        }
    }

    func expGainTimerEvent(_ steps: Double) {
        newSteps = Int(steps)
        stepCount += Int64(steps)
        exp += Int64(Double(steps) * expGainScalingFactor)
        while exp >= expCap {
            levelUp()
        }
    }

    deinit {
        streakTimer?.invalidate()
    }
}
