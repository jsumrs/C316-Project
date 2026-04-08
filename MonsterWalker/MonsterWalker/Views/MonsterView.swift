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
    VStack(spacing: Theme.xs) {

      // MARK: Name and Level Container
      HStack (alignment: .center, spacing: Theme.sm) {

        Text("Trogdor the Burninator")
          .font(Theme.indieflower.scaled(by: 0.75))
          .foregroundStyle(Theme.textPrimary)
          .lineLimit(1)
          .minimumScaleFactor(0.6)
          .frame(maxWidth: .infinity, alignment: .leading)

        // MARK: Level and Steps Container
        VStack(alignment: .trailing, spacing: 0) {
          Text("Lv. \(monster.experienceComponent.level)")
            .font(Theme.indieflower.scaled(by: 0.55))
          Text("\(monster.experienceComponent.getStepsToNextLevel()) steps to go")
            .font(Theme.indieflower.scaled(by: 0.45))
        }
        .frame(width: 110, alignment: .trailing)
        .foregroundStyle(Theme.textPrimary)
      }
      .padding(.horizontal, Theme.sm)
      .padding(.top, Theme.xs)

      // MARK: Experience Bar
      ProgressView(value: Double(monster.experienceComponent.exp), total: Double(monster.experienceComponent.expCap))
        .tint(Theme.primary)
        .padding(.horizontal, Theme.sm)
        .padding(.bottom, Theme.xs)
    }
    .background(Theme.secondary)
    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    .overlay(
      RoundedRectangle(cornerRadius: Theme.cornerRadius)
        .strokeBorder(.black.opacity(0.3), lineWidth: 0.5)
    )
    .overlay(
      Image("SketchBorder")
        .resizable()
    )
    .padding(.horizontal, Theme.sm)
    .rotationEffect(Angle(degrees: -1))
  }
}

#Preview {
  MonsterView()
}
