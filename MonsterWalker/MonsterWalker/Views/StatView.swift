import SwiftUI

struct StatView: View {
  @Bindable var monster: MonsterModel
  var body: some View {
    VStack(alignment: .leading, spacing: Theme.xs) {
      Text("Stats")
        .font(Theme.title)
        .foregroundStyle(Theme.textPrimary)
        .padding(.bottom, Theme.sm)
      
      StatRow(label: "Happiness", value: String(format: "%.2f", monster.happiness))
      StatRow(label: "Energy", value: String(format: "%.2f", monster.energy))
      StatRow(label: "expGainScalingFactor", value: String(format: "%.2f", monster.experienceComponent.expGainScalingFactor))
      StatRow(label: "stepCount", value: "\(monster.experienceComponent.stepCount)")
      StatRow(label: "exp", value: "\(monster.experienceComponent.exp)")
      StatRow(label: "expCap", value: "\(monster.experienceComponent.expCap)")
      StatRow(label: "level", value: "\(monster.experienceComponent.level)")
      StatRow(label: "streak", value: "\(monster.experienceComponent.streak)")
      StatRow(label: "evolutionIndex", value: "\(monster.experienceComponent.evolutionIndex)")
    }
    .padding(Theme.md)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Theme.background)
  }
}

struct StatRow: View {
  let label: String
  let value: String
  
  var body: some View {
    HStack {
      Text(label)
        .font(Theme.body)
        .foregroundStyle(Theme.textSecondary)
      Spacer()
      Text(value)
        .font(Theme.body)
        .foregroundStyle(Theme.textPrimary)
    }
    .padding(.horizontal, Theme.md)
    .background(Theme.background)
    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
  }
}
