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


@MainActor
@Model
class MonsterModel {
    // MARK: - Globals
    public static var maxHappiness: Double = 100
    public static var maxEnergy: Double = 100

    // MARK: - Persisted Properties
    public var happiness: Double
    public var energy: Double

    var lastHappinessReduction: Date
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
        energyReductionInterval = 10.0
        happinessReductionInterval = 7.0
        experienceComponent = Experience(happiness: happiness, energy: energy)
    }

    // Call this after SwiftData rehydrates the object (e.g. in .onAppear)
    func start() async {
        guard energyTimer == nil else { return }
        experienceComponent.happiness = happiness
        experienceComponent.energy = energy

        await calculateTimePassed()
        startTimers()
        await experienceComponent.start()
    }

    // MARK: - Public Functions

    public func feed(_ value: Double = 20) {
        energy = min(energy + value, MonsterModel.maxEnergy)
        syncExperience()
    }

    public func pet() {
        happiness = min(happiness + 25.0, MonsterModel.maxHappiness)
        syncExperience()
    }

    // MARK: - Private Helpers

    private func syncExperience() {
        experienceComponent.happiness = happiness
        experienceComponent.energy = energy
        experienceComponent.changeExpScalingFactor()
    }

    private func calculateTimePassed() async {
        let happinessTimePassed = Date().timeIntervalSince(lastHappinessReduction)
        var happinessCounter = Int(happinessTimePassed / happinessReductionInterval)
        while happinessCounter > 0 {
            happinessTimerEvent()
            happinessCounter -= 1
        }
    }

    func startTimers() {
        happinessTimer = Timer.publish(every: happinessReductionInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.happinessTimerEvent()
            }

        energyTimer = Timer.publish(every: energyReductionInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    await self.energyTimerEvent()
                }
            }
    }

    private func happinessTimerEvent() {
        let happinessDecrement = 2.0
        happiness = max(happiness - happinessDecrement, 0)
        lastHappinessReduction = Date()
        syncExperience()
    }

    private func energyTimerEvent() async {
        let newSteps = await experienceComponent.stepCounter.getNewSteps()
        let energyReductionScalingFactor = 0.01
        
        energy = max(0, energy - (energyReductionScalingFactor * newSteps))
        syncExperience()

        experienceComponent.expGainTimerEvent(newSteps)
    }

    deinit {
        happinessTimer?.cancel()
        energyTimer?.cancel()
    }
}
