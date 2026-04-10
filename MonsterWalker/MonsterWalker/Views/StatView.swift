import SwiftUI

// MARK: - Meme label map
private let memeTags: [String: String] = [
    "Happiness": "bestie energy",
    "Energy": "RED BULL??",
    "expGainScalingFactor": "the grind",
    "stepCount": "steps? in this economy?",
    "exp": "touch grass xp",
    "expCap": "ceiling? shattered",
    "level": "she's leveling UP",
    "streak": "no cap",
    "evolutionIndex": "glow up arc"
]

private let vibeColor: [String: Color] = [
    "Happiness": Color(red: 0.88, green: 0.0, blue: 0.42),
    "Energy": Color(red: 0.77, green: 0.48, blue: 0.0),
    "level": Color(red: 0.88, green: 0.0, blue: 0.42),
    "streak": Color(red: 0.88, green: 0.0, blue: 0.42),
    "evolutionIndex": Color(red: 0.88, green: 0.0, blue: 0.42)
]

struct StatView: View {
    @Bindable var monster: MonsterModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.xs) {
                BowView()
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, Theme.xs)
                
                VStack(spacing: 2) {
                    Text("stats (she's real)")
                        .font(Theme.title)
                        .foregroundStyle(Color(red: 0.48, green: 0.12, blue: 0.27))
                    Text("lowkey a banger build ngl")
                        .font(.system(size: 12, weight: .regular))
                        .italic()
                        .foregroundStyle(Color(red: 0.63, green: 0.22, blue: 0.37))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, Theme.sm)
                
                MemeStatRow(label: "Happiness",     value: String(format: "%.2f", monster.happiness))
                MemeStatRow(label: "Energy",         value: String(format: "%.2f", monster.energy))
                
                SectionDivider(title: "deep lore (exp stuff)")
                
                MemeStatRow(label: "expGainScalingFactor", value: String(format: "%.2f", monster.experienceComponent.expGainScalingFactor))
                MemeStatRow(label: "stepCount",      value: "\(monster.experienceComponent.stepCount)")
                MemeStatRow(label: "exp",            value: "\(monster.experienceComponent.exp)")
                MemeStatRow(label: "expCap",         value: "\(monster.experienceComponent.expCap)")
                
                SectionDivider(title: "the real ones")
                
                MemeStatRow(label: "level",          value: "\(monster.experienceComponent.level)")
                MemeStatRow(label: "streak",         value: "\(monster.experienceComponent.streak)")
                MemeStatRow(label: "evolutionIndex", value: "\(monster.experienceComponent.evolutionIndex)")
            }
            .padding(Theme.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 1.0, green: 0.84, blue: 0.88))
    }
}

// MARK: - Section divider
struct SectionDivider: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .regular))
            .tracking(1)
            .foregroundStyle(Color(red: 0.77, green: 0.38, blue: 0.50))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }
}

// MARK: - Meme stat row
struct MemeStatRow: View {
    let label: String
    let value: String
    
    private var memeTag: String { memeTags[label] ?? "" }
    private var valueColor: Color { vibeColor[label] ?? Color(red: 0.48, green: 0.12, blue: 0.27) }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(Theme.body)
                    .foregroundStyle(Color(red: 0.63, green: 0.22, blue: 0.37))
                if !memeTag.isEmpty {
                    Text(memeTag)
                        .font(.system(size: 10, weight: .regular))
                        .italic()
                        .foregroundStyle(Color(red: 0.83, green: 0.33, blue: 0.60))
                }
            }
            Spacer()
            Text(value)
                .font(Theme.body)
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, Theme.md)
        .padding(.vertical, 8)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Color(red: 0.96, green: 0.72, blue: 0.80), lineWidth: 0.5)
        )
    }
}

struct BowView: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let bowColor = Color(red: 0.9, green: 0.2, blue: 0.4)
            
            // Left loop
            var leftLoop = Path()
            leftLoop.move(to: CGPoint(x: cx, y: cy))
            leftLoop.addCurve(
                to: CGPoint(x: cx - 38, y: cy - 18),
                control1: CGPoint(x: cx - 10, y: cy - 28),
                control2: CGPoint(x: cx - 30, y: cy - 32)
            )
            leftLoop.addCurve(
                to: CGPoint(x: cx, y: cy),
                control1: CGPoint(x: cx - 46, y: cy - 2),
                control2: CGPoint(x: cx - 20, y: cy + 10)
            )
            context.fill(leftLoop, with: .color(bowColor.opacity(0.85)))
            context.stroke(leftLoop, with: .color(bowColor), lineWidth: 1)
            
            // Right loop
            var rightLoop = Path()
            rightLoop.move(to: CGPoint(x: cx, y: cy))
            rightLoop.addCurve(
                to: CGPoint(x: cx + 38, y: cy - 18),
                control1: CGPoint(x: cx + 10, y: cy - 28),
                control2: CGPoint(x: cx + 30, y: cy - 32)
            )
            rightLoop.addCurve(
                to: CGPoint(x: cx, y: cy),
                control1: CGPoint(x: cx + 46, y: cy - 2),
                control2: CGPoint(x: cx + 20, y: cy + 10)
            )
            context.fill(rightLoop, with: .color(bowColor.opacity(0.85)))
            context.stroke(rightLoop, with: .color(bowColor), lineWidth: 1)
            
            // Left tail
            var leftTail = Path()
            leftTail.move(to: CGPoint(x: cx, y: cy))
            leftTail.addCurve(
                to: CGPoint(x: cx - 28, y: cy + 28),
                control1: CGPoint(x: cx - 8, y: cy + 8),
                control2: CGPoint(x: cx - 22, y: cy + 14)
            )
            leftTail.addCurve(
                to: CGPoint(x: cx, y: cy),
                control1: CGPoint(x: cx - 18, y: cy + 30),
                control2: CGPoint(x: cx - 6, y: cy + 16)
            )
            context.fill(leftTail, with: .color(bowColor))
            
            // Right tail
            var rightTail = Path()
            rightTail.move(to: CGPoint(x: cx, y: cy))
            rightTail.addCurve(
                to: CGPoint(x: cx + 28, y: cy + 28),
                control1: CGPoint(x: cx + 8, y: cy + 8),
                control2: CGPoint(x: cx + 22, y: cy + 14)
            )
            rightTail.addCurve(
                to: CGPoint(x: cx, y: cy),
                control1: CGPoint(x: cx + 18, y: cy + 30),
                control2: CGPoint(x: cx + 6, y: cy + 16)
            )
            context.fill(rightTail, with: .color(bowColor))
            
            // Center knot
            context.fill(
                Path(ellipseIn: CGRect(x: cx - 7, y: cy - 7, width: 14, height: 14)),
                with: .color(bowColor)
            )
            context.fill(
                Path(ellipseIn: CGRect(x: cx - 4, y: cy - 4, width: 8, height: 8)),
                with: .color(.white.opacity(0.4))
            )
        }
        .frame(width: 100, height: 70)
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
