//
//  Level.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-16.
//

import Combine
import Foundation
import UIKit
import SwiftData
import SwiftUI


class Experience : ObservableObject {
    
    @Published var stepCount : Int64
    @Published var exp : Int64
    @Published var expCap : Int64
    @Published var expGainScalingFactor : Double //Maybe private
    @Published var level : Int
    @Published var evolutionLevels : [Int] //Maybe private
    @Published var evolutionIndex : Int
    private var expGainTimer : AnyCancellable?
    
    @Published var streak : Int
    @Published var lastStreakDate : Date
    @Published var streakTimer : Timer?
    
    //MonsterModel Fields
    @Binding var happiness: Double
    @Binding var energy: Double
    
    
    init(happiness: Binding<Double>, energy: Binding<Double>){
        
        lastStreakDate = Date()
        streak = 0
        exp = 0
        expCap = 1000
        expGainScalingFactor = 1.0
        stepCount = 0
        level = 0
        evolutionLevels = [0,20,50,70,100]
        evolutionIndex = 0
        self._happiness = happiness
        self._energy = energy
        
        
        startTimers()
    }
    
    private func startTimers() {
        
        expGainTimer = Timer.publish(every: 10.0, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                expGainTimerEvent()
        }
        
        var components = DateComponents()
        components.hour = 23
        components.minute = 58
        let targetTime = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)!
        
        streakTimer = Timer(fire: targetTime, interval: 0, repeats: false) { _ in
            self.streakTimerEvent()
        }
        
        RunLoop.main.add(streakTimer!, forMode: .common)
    }
    
    private func changeExpScalingFactor() { // Need to modify with streak
        var baseScalingFactor : Double = 1.0
        
        baseScalingFactor *= Double(streak) * 0.5
        
        if (baseScalingFactor > 5.0){
            baseScalingFactor = 5.0
        }
        
        expGainScalingFactor = baseScalingFactor
    }
    
    private func levelUp(){
        level += 1
        let expCapScalingFactor : Double = 1.05
        expCap = Int64(Double(expCap) * expCapScalingFactor)
        
        if  (evolutionIndex + 1 < evolutionLevels.count &&
             level >= evolutionLevels[evolutionIndex + 1]){
            evolutionIndex += 1
        }
        
    }
    
    private func expGainTimerEvent() {
        let newSteps = 0 //get new stepCount and add to stepCount
        stepCount += Int64(newSteps)
        exp += Int64(Double(newSteps) * expGainScalingFactor)
        if (exp >= expCap) {
            levelUp()
        }
    }
    
    private func streakTimerEvent() {
        let tempDate = Date()
        let dailySteps = 0 //TEMP WILL CALL DAILY STEPS FUNCTION
        if (Calendar.current.isDateInYesterday(lastStreakDate) &&
            dailySteps >= 5000 && energy > 0 && happiness > 0) {
            lastStreakDate = tempDate
            streak += 1
        }
    }
    
    deinit {
        // This ensures timers stops before deallocation
        streakTimer?.invalidate()
        expGainTimer?.cancel()
    }
    
    
    
    
    
    
    
    
    
    
}
