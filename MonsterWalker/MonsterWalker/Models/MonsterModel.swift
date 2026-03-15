//
//  Monster.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-13.
//

import Combine
import Foundation
import UIKit


/*
 Things left to Implment:
 - Loading/Saving
 - Streaks Multiplier
 - Detecting when App is in foreground vs Background
 
 */
class MonsterModel : ObservableObject {
    
    @Published var stepCount : Int64
    
    @Published var exp : Int64
    @Published var expCap : Int64
    @Published var expGainScalingFactor : Double
    
//    @Published var streakCount : Int
//    private var lastActive = Date()
    
    @Published var level : Int
    
    @Published var happiness : Double
    private var happinessTimer : AnyCancellable?

    @Published var energy : Double
    private var energyTimer : AnyCancellable?
        
    init() {
        
        //Will implement loading and saving functionality later
        
        //Using base values for now
        exp = 0
        expCap = 1000
        expGainScalingFactor = 1.0
        stepCount = 0
        level = 0
        happiness = 50
        energy = 100
        
        
        //Load variables from UserDefaults or hardcoded default if not initialized
        
        
        happinessTimer = Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                happinessTimerEvent()
            }
        energyTimer = Timer.publish(every: 600, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                energyTimerEvent()
            }
    }
    
    //Public functions
    public func feed(_ value: Double = 20) {
        let maxEnergy = 100.0
        if (energy + value <= maxEnergy){
            energy += value
            return
        }
        
        energy = maxEnergy
        
    }
    
    public func pet(){
        let value = 25.0
        let maxHappiness = 100.0
        if (happiness + value <= maxHappiness){
            happiness += value
            return
        }
        
        happiness = maxHappiness
        
    }
    
    
    
    
    //Private functions
    private func changeExpScalingFactor() { // Need to modify with streak
        var baseScalingFactor : Double = 1.0
        if (energy == 0) {
            baseScalingFactor -= 0.25
        }
        if (happiness == 0) {
            baseScalingFactor -= 0.25
        }
        expGainScalingFactor = baseScalingFactor
    }
    
    private func levelUp(){
        level += 1
        var expCapScalingFactor : Double = 1.05
        expCap = Int64(Double(expCap) * expCapScalingFactor)
    }
    
    private func gainExperience() {
        var newSteps = 0 //get new stepCount and add to stepCount
        stepCount += Int64(newSteps)
        exp += Int64(Double(newSteps) * expGainScalingFactor)
        if (exp >= expCap) {
            levelUp()
        }
        
    }
    
    private func happinessTimerEvent() {
        let happinessDecrement = 20.0
        if happiness >= happinessDecrement {
            happiness -= 20.0
        }
    }

    private func energyTimerEvent() {
        
        //Base Energy
        let energyDecrement = 1.0
        if energy - energyDecrement >= 0 {
            energy -= energyDecrement
        }
        
        let stepsSinceLast = 0.0 //PLACEHOLDER call last steps function once implemented
        let energyReductionScalingFactor = 0.01
        
        let temp = energy - (energyReductionScalingFactor * stepsSinceLast)
        
        if (temp >= 0){
            energy = temp
            return
        }
        
        energy = 0
        
    }
    
//    private func SaveData() {
//        UserDefaults.standard.set(exp, forKey: "exp")
//
//    }
    
    deinit {
        // This ensures timers stops before deallocation
        happinessTimer?.cancel()
        energyTimer?.cancel()
    }
    
}
