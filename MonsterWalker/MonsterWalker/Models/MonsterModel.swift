//
//  Monster.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-13.
//

import Combine
import Foundation
import UIKit
import SwiftData
import SwiftUI

/*
 Things left to Implment:
 - Loading/Saving
 - Streaks Multiplier
 
 */
class MonsterModel : ObservableObject {
    
    //Can be isolated into Level Class if needed
    
    @Published var happiness : Double
    @Published var energy : Double
    @Published var ExperienceComponent : Experience? //NOT SURE IF OPTIONAL IS OK HERE
    
    private var energyReductionInterval : Double
    private var lastEnergyReduction : Date
    private var energyTimer : AnyCancellable?
    
    private var happinessReductionInterval : Double
    private var lastHappinessReduction : Date
    private var happinessTimer : AnyCancellable?
    
    
    init() {
        
        //LOAD DATE USING SWIFTDATA
        
        //DEFAULT VALUES IF NO SAVE EXISTS YET

        happiness = 50
        energy = 100
        lastHappinessReduction = Date()
        lastEnergyReduction = Date()
        energyReductionInterval = 600.0
        happinessReductionInterval = 3600.0
                
        
        let happinessBinding = Binding(
            get: { self.happiness },
            set: { self.happiness = $0 }
        )
                
        let energyBinding = Binding(
            get: { self.energy },
            set: { self.energy = $0 }
        )

        ExperienceComponent = Experience(
            happiness: happinessBinding,
            energy: energyBinding
        )
        
        calculateTimePassed()
        
        startTimers()


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
    
    //Initilization functions
    private func calculateTimePassed() {
                
        // Subtract dates to get time interval in seconds
        let happinessTimePassed = Date().timeIntervalSince(lastHappinessReduction)
        let energyTimePassed = Date().timeIntervalSince(lastEnergyReduction)
        
        var happinessCounter = Int(happinessTimePassed / happinessReductionInterval)
        while (happinessCounter > 0) {
            happinessTimerEvent()
        }
        var energyCounter = Int(energyTimePassed / energyReductionInterval)
        while (energyCounter > 0) {
            energyTimerEvent()
        }
        
    }
    
    private func startTimers() {
        happinessTimer = Timer.publish(every: happinessReductionInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                happinessTimerEvent()
            }
        
        energyTimer = Timer.publish(every: energyReductionInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                energyTimerEvent()
            }

    }
    
    //Private Monster Logic functions
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
