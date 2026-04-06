//
//  DevControlView.swift
//  MonsterWalker
//
//  Created by Brandon Hay on 2026-03-20.
//

import SwiftUI
import SwiftData

struct DevControlView: View {
    @Environment(\.modelContext) private var context
    @Query private var monsters: [MonsterModel]
    @State private var monsterModel: MonsterModel? = nil
    
    var body: some View {
        Group {
            if let monster = monsterModel {
                DevControlLoadedView(monster: monster)
            } else {
                ProgressView() // Loading state
            }
        }
       
    }
}







#Preview {
    DevControlView()
}
