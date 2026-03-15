//
//  ContentView.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-13.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var animator = ImageAnimator(
            intervalSec: 1,
            animMap: [AnimType.idle: ["Horse_Icon","Cat_Icon"]]
        )
    
    var body: some View {
                 
        VStack {
            Image(animator.currentName)
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
