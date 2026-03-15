//
//  ImageAnimator.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-13.
//

import Combine
import UIKit

enum AnimType : Hashable{
    case idle
    case sleep
    case eat
}

/*
Class used to switch between images for a simulated animation.
 
To use:
    Create an instance as a field of the view struct you want:
 
    animMap is a Map of the Animation type you want (defined in the above Enum) and the array of image names to animate through
 
    Ensure idle is included in the AnimMap as that is the default value
 
    Then make an Image constructor within the view body
 

e.g.
 -----------------------------------------------------------------
 
    @StateObject var animator = ImageAnimator(
         intervalSec: 1,
         animMap: [AnimType.idle: ["Monster_Idle1","Monster_Idle2"]]
     )
 
 
    var body: some View {
        Image(animator.currentName)
    }
 
 -----------------------------------------------------------------
*/
class ImageAnimator : ObservableObject {
    
    private var cycleTimer : AnyCancellable?
    @Published var animationTypeMap : [AnimType : [String]]
    let timerInterval : Double //Seconds

    private var currentindex : Int = 0
    private var currentAnim : AnimType = AnimType.idle
    @Published var currentName : String
    
    init(intervalSec : Double, animMap: [AnimType : [String]]) {
        self.timerInterval = intervalSec
        self.animationTypeMap = animMap
        currentName = animMap[AnimType.idle]![0] //Needs to have an AnimType.idle in the Map
        cycleTimer = Timer.publish(every: timerInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                TimerEvent()
            }
    }
    
    func changeAnimation(_ type: AnimType) {
        currentAnim = type
        currentindex = 0
        startCycle()
    }
    
    
    //Timer Related Functions
    private func TimerEvent() {
        let tempArr = self.animationTypeMap[currentAnim]! //only uses empty string array if switching to an animation not in the map
        currentName = tempArr[currentindex]
        currentindex = (currentindex + 1) % tempArr.count
    }
        
    func startCycle() {
            stopCycle() // Cancel existing
            cycleTimer = Timer.publish(every: timerInterval, on: .main, in: .common)
                .autoconnect()
                .sink { [unowned self] _ in
                    TimerEvent()
                }
    }
    
    func stopCycle() {
        cycleTimer?.cancel()
        cycleTimer = nil
    }
    
    deinit {
        cycleTimer?.cancel()  // This ensures timer stops before deallocation
    }
    
    
}
