import SwiftUI

struct EnergyView: View {
    // View Specific
    private let meatSpacing: CGFloat = 4
    private let numOfMeats = 5
    let energy: Double

    private let rotations: [Double]

    init(energy: Double) {
        self.energy = energy
        self.rotations = (0..<5).map { _ in Double.random(in: -2...2) }
    }

    // Data In
    var meatEnergyWorth: CGFloat {
        MonsterModel.maxEnergy / CGFloat(numOfMeats)
    }

    var body: some View {
        HStack(spacing: meatSpacing) {
            ForEach(0..<numOfMeats, id: \.self) { i in
                MeatIcon(
                    fillAmount: calcFillAmt(for: i),
                    rotation: rotations[i]
                )
            }
        }
        .padding(Theme.md)
        .rotationEffect(.degrees(rotations[0]))
    }

    func calcFillAmt(for meatIndex: Int) -> CGFloat {
        let raw =
            ((energy - (CGFloat(meatIndex) * meatEnergyWorth)) / meatEnergyWorth)
        return raw < 0 ? 0 : raw > 1 ? 1 : raw
    }
}

struct MeatIcon: View {
    var fillAmount: Double
    var rotation: Double

    var body: some View {
        Image("MeatOutline")
            .resizable()
            .scaledToFit()
            .hidden()
            .overlay {
                GeometryReader { geo in
                    Image("MeatFill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.red)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .mask(alignment: .leading) {
                            Rectangle()
                                .frame(width: geo.size.width * fillAmount)
                                .animation(
                                    .easeOut(duration: 1.5),
                                    value: fillAmount
                                )
                        }
                }
                Image("MeatOutline")
                    .resizable()
                    .scaledToFit()
            }

            .rotationEffect(Angle(degrees: rotation))
    }
}
