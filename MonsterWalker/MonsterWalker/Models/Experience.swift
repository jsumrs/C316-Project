//
//  Experience.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-16.
//

import Combine
import Foundation
import UIKit
import SwiftData
import SwiftUI

/*
Interaction:

    The Experience model is entirely READ ONLY as it updates itself with timers and the StepCounter.

    It needs to be started using the startTimers() function only if loaded from swiftData and not from init()

*/
@Model
class Experience{

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
    @Transient var expGainTimer: AnyCancellable? = nil
    @Transient var streakTimer: Timer? = nil

    @Transient var happiness: Double = 0.0
    @Transient var energy: Double = 0.0
    

    init(happiness: Double = 0.0, energy: Double = 0.0) {

        lastStreakDate = Date()
        streak = 0
        exp = 0
        expCap = 1000
        expGainScalingFactor = 1.0
        stepCount = 0
        level = 0
        evolutionLevels = [0, 20, 50, 70, 100]
        evolutionIndex = 0
        newSteps = 0
        self.happiness = happiness
        self.energy = energy
        stepCounter = StepCounterModel()
    }

    func start(){
        guard expGainTimer == nil else { return }//if already started do nothing

        expGainTimer = Timer.publish(every: 10.0, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                    expGainTimerEvent()
            }
        setupStreakTimer()
        
        checkStreakOnLaunch()
        
    }
    
    private func setupStreakTimer() {
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        let targetTime = Calendar.current.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime
        )!//WHY EXCLAMATION MARK

        let t = Timer(fire: targetTime, interval: 0, repeats: false) { [weak self] _ in
            self?.streakTimerEvent()
        }
        streakTimer = t
        RunLoop.main.add(t, forMode: .common)
    }

    func checkStreakOnLaunch() {
        let calendar = Calendar.current
        let now = Date()
        
        guard !calendar.isDateInToday(lastStreakDate) else { return }
        
        if calendar.isDateInYesterday(lastStreakDate) {
            
            stepCounter.getNewSteps{ steps in
                
                if steps >= 5000 && self.energy > 0 {
                    self.streak += 1
                } else {
                    self.streak = 0
                }
            }
                
        } else {
            // Missed more than one day
            self.streak = 0
        }
            
            lastStreakDate = now
            changeExpScalingFactor()
    }
        

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

    private func levelUp() {
        level += 1
        let expCapScalingFactor: Double = 1.15
        expCap = Int64(Double(expCap) * expCapScalingFactor)

        if evolutionIndex + 1 < evolutionLevels.count &&
           level >= evolutionLevels[evolutionIndex + 1] {
            evolutionIndex += 1
        }
    }

    private func expGainTimerEvent () {
        
        stepCounter.getNewSteps{steps in
            
            self.stepCount += Int64(steps)
            self.newSteps = Int(steps)
            self.exp += Int64(Double(steps) * self.expGainScalingFactor)
            while self.exp >= self.expCap {
                self.levelUp()
            }
            
        }
    }

    private func streakTimerEvent() {        
        let tempDate = Date()
    
        stepCounter.getTodaysSteps{steps in
            if steps >= 5000 && self.energy > 0 {
                self.streak += 1
            } else {
                self.streak = 0
            }
            self.lastStreakDate = tempDate
            self.changeExpScalingFactor()
            self.setupStreakTimer()
        }
    }
    

    deinit {
        streakTimer?.invalidate()
        expGainTimer?.cancel()
        expGainTimer = nil
    }
}
