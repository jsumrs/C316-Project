import SwiftData
import SwiftUI

struct MonsterView: View {
  @Environment(\.modelContext) private var context
  @Query private var monsters: [MonsterModel]
  @State private var monsterModel: MonsterModel? = nil

  var body: some View {
    VStack {

      InfoPlate()
      Image("Monster")
        .padding(Theme.xl)

      EnergyView()
      Button("Feed") { print("Fed trogdor") }
    }
    .buttonStyle(CustomButtonStyle())
    .backgroundStyle(Theme.background)
  }

  func InfoPlate() -> some View {
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
