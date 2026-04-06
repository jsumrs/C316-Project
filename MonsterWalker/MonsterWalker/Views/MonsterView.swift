import SwiftData
import SwiftUI

struct MonsterView: View {
  @Environment(\.modelContext) private var context
  @Query private var monsters: [MonsterModel]
  @State private var monsterModel: MonsterModel? = nil
  @State private var showStats = false

  var body: some View {
    Group {
      if let monster = monsterModel {
        VStack {
          InfoPlate(monster)
          Image("Monster")
            .padding(Theme.xl)
            .onTapGesture {
              monster.pet()
            }

          EnergyView(monster: monster)
          Button("Feed") {
            monster.feed()
          }
          .buttonStyle(CustomButtonStyle())
          Button("Stats") { showStats = true }
            .font(Theme.caption)
            .foregroundStyle(Theme.textSecondary)
            .padding()
        }
        .backgroundStyle(Theme.background)
        .sheet(isPresented: $showStats) {
          StatView(monster: monster)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
      } else {
        ProgressView()
      }
    }
    .onAppear {
      if let existing = monsters.first {
        monsterModel = existing
      } else {
        let newMonster = MonsterModel(happiness: 50, energy: 100)
        context.insert(newMonster)
        monsterModel = newMonster
        do {
          try context.save()  // Explicit save to ensure persistence.
        } catch {
          print("Failed to save new monster: \(error)")
        }
      }
      Task {
        await monsterModel?.start()
      }
    }
  }

  func InfoPlate(_ monster: MonsterModel) -> some View {
    // MARK: Info Container
    VStack(spacing: Theme.sm) {

      // MARK: Name and Level Container
      HStack {

        Text("Trogdor the Burninator")
          .font(Theme.indieflower.scaled(by: 0.8))

        // MARK: Level and Steps Container
        VStack(alignment: .trailing) {
          Text("Lv. 1")
          Text("x steps to go")  // Calculate the amount of steps to go before next level up. Do the math with the multiplier.
        }
      }

      // MARK: Experience Bar
      ProgressView(value: 400, total: 1000)
        .tint(Theme.primary)
        .border(.black, width: 0.5)
        .padding(.bottom, Theme.xs)
    }
    .background(Theme.secondary)
    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    .overlay(
      Image("SketchBorder")
        .resizable()
    )
    .padding(.horizontal, Theme.sm)
    .font(Theme.indieflower.scaled(by: 0.66))
  }
}

#Preview {
  MonsterView()
}
