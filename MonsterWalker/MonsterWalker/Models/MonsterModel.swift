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
Interaction:

    The Monster model is almost entirely READ ONLY as it updates itself with timers.

    It needs to be started using the start() function (example below) when the associated view is loaded

    The ONLY ways you should be manipulating or writing to it are using the 2 public functions:
        - feed(_ value: Double = 20)
        - pet()

Implementation Example:

//Below is a basic example of how you should create the MonsterModel in the associated MonsterView

struct MonsterView: View {
    @Environment(\.modelContext) private var context
    //calling environment variable so we can add a new
    //monster to it if we don't have one saved already.
    //Only needed when inserting.

    @Query private var monsters: [MonsterModel]
    //@Query returns an optional array of type: MonsterModel

    //if MonsterModel exists load it, otherwise create one and save it
    private var monster: MonsterModel {
        if let existing = monsters.first {
            return existing         // SwiftData rehydrated this from disk
        }

        let newMonster = MonsterModel(happiness: 50, energy: 100)
        context.insert(newMonster)  // First launch — persist it
        return newMonster
    }

    var body: some View {
        GameView(monster: monster)
            .onAppear {
                monster.start()
            }
    }
}
*/

/*
 Improvements:
 - calculateTimePassed() after a week of logout gets kinda slow. Change later only if needed
*/


@Model
class MonsterModel {

    // MARK: - Persisted Properties
    var happiness: Double
    var energy: Double

    var lastHappinessReduction: Date
    var lastEnergyReduction: Date
    var energyReductionInterval: Double
    var happinessReductionInterval: Double

    // MARK: - Relationship
    @Relationship(deleteRule: .cascade) var experienceComponent: Experience

    // MARK: - Transient (runtime-only)
    @Transient var energyTimer: AnyCancellable? = nil
    @Transient var happinessTimer: AnyCancellable? = nil


    init(happiness: Double, energy: Double) {
        self.happiness = happiness
        self.energy = energy
        lastHappinessReduction = Date()
        lastEnergyReduction = Date()
        energyReductionInterval = 5.0
        happinessReductionInterval = 7.0
        experienceComponent = Experience(happiness: happiness, energy: energy)
    }

    // Call this after SwiftData rehydrates the object (e.g. in .onAppear)
    func start() {
        guard energyTimer == nil else { return }//if already started do nothing
        
        experienceComponent.happiness = happiness
        experienceComponent.energy = energy
        
        calculateTimePassed()
        startTimers()

        experienceComponent.start()
    }

    // MARK: - Public Functions

    public func feed(_ value: Double = 20) {
        let maxEnergy = 100.0
        energy = min(energy + value, maxEnergy)
        syncExperience()
    }

    public func pet() {
        let maxHappiness = 100.0
        happiness = min(happiness + 25.0, maxHappiness)
        syncExperience()
    }

    // MARK: - Private Helpers

    private func syncExperience() {
        experienceComponent.happiness = happiness
        experienceComponent.energy = energy
        experienceComponent.changeExpScalingFactor()
    }

    private func calculateTimePassed() {
        let happinessTimePassed = Date().timeIntervalSince(lastHappinessReduction)
        let energyTimePassed = Date().timeIntervalSince(lastEnergyReduction)

        var happinessCounter = Int(happinessTimePassed / happinessReductionInterval)
        while happinessCounter > 0 {
            happinessTimerEvent()
            happinessCounter -= 1
        }

        var energyCounter = Int(energyTimePassed / energyReductionInterval)
        while energyCounter > 0 {
            energyTimerEvent()
            energyCounter -= 1
        }
    }

    func startTimers() {
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

    private func happinessTimerEvent() {
        let happinessDecrement = 2.0
        happiness = max(happiness - happinessDecrement, 0)
        lastHappinessReduction = Date()
        syncExperience()
    }

    private func energyTimerEvent() {

        let stepsSinceLast = 20.0 //GET REAL STEPS FROM THE STEP COUNTER HERE
        let energyReductionScalingFactor = 0.01 //Every 100 steps energy goes down by 1
        energy = max(0, energy - (energyReductionScalingFactor * stepsSinceLast))

        lastEnergyReduction = Date()
        syncExperience()
    }

    deinit {
        happinessTimer?.cancel()
        energyTimer?.cancel()
    }
}
