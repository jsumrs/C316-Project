//
//  ContentView.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-13.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
      MonsterView()

//      ZStack (alignment: .topLeading) {
//        
//          DevControlView()
//              .zIndex(1)
//          MonsterView()
//      }
    }
}

#Preview {
    ContentView()
    .background(Theme.background.ignoresSafeArea())
}
