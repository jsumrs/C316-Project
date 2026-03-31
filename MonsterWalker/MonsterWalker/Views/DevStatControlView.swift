import SwiftUI

struct DevStatControlView: View  {
    @Bindable var monster: MonsterModel
    var body: some View {
            VStack(alignment: .leading){
                StatRowView(label: "Happiness", value: $monster.happiness)
                StatRowView(label: "Energy", value: $monster.energy, step: 2)
                StatRowView(label: "expGainScalingFactor", value: $monster.experienceComponent.expGainScalingFactor, step: 0.1)
                StatRowInt64View(label: "stepCount", value: $monster.experienceComponent.stepCount, step: 100)
                StatRowInt64View(label: "exp", value: $monster.experienceComponent.exp, step: 100)
                StatRowInt64View(label: "expCap", value: $monster.experienceComponent.expCap)
                StatRowIntView(label: "level", value: $monster.experienceComponent.level, step: 1)
                StatRowIntView(label: "streak", value: $monster.experienceComponent.streak, step: 1)
                StatRowIntView(label: "evolutionIndex", value: $monster.experienceComponent.evolutionIndex, step: 1)
        }
    }
    
}

struct StatRowView: View {
    let label: String
    @Binding var value: Double
    let step: Double
    
    init(label: String, value: Binding<Double>, step: Double = 10) {
        self.label = label
        self._value = value
        self.step = step
    }
    
    var body: some View {
        StatRowLayout(label: label, valueText: String(format: "%.2f", value)) {
            Button("-") { value = max(0, value - step) }
            Button("+") { value += step }
        }
    }
}

struct StatRowIntView: View {
    let label: String
    @Binding var value: Int
    let step: Int
    
    init(label: String, value: Binding<Int>, step: Int = 10) {
        self.label = label
        self._value = value
        self.step = step
    }
    
    var body: some View {
        StatRowLayout(label: label, valueText: "\(value)") {
            Button("-") { value = max(0, value - step) }
            Button("+") { value += step }
        }
    }
}

struct StatRowInt64View: View {
    let label: String
    @Binding var value: Int64
    let step: Int64
    
    init(label: String, value: Binding<Int64>, step: Int64 = 10) {
        self.label = label
        self._value = value
        self.step = step
    }
    
    var body: some View {
        StatRowLayout(label: label, valueText: "\(value)") {
            Button("-") { value = max(0, value - step) }
            Button("+") { value += step }
        }
    }
}

struct StatRowLayout<Buttons: View>: View {
    let label: String
    let valueText: String
    @ViewBuilder let buttons: () -> Buttons
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(valueText)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
            }
            Spacer()
            HStack(spacing: 0) {
                buttons()
                    .buttonStyle(StepButtonStyle())
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct StepButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .fontWeight(.medium)
            .frame(width: 36, height: 36)
            .background(configuration.isPressed ? Color.primary.opacity(0.15) : Color.primary.opacity(0.08))
    }
}
