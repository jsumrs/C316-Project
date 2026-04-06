import SwiftUI

struct EnergyView: View {
    // View Specific
    private let meatSpacing: CGFloat = 4
    private let numOfMeats = 5
    
    // Data In
  @Bindable var monster: MonsterModel
    var meatEnergyWorth: CGFloat {
      MonsterModel.maxEnergy / CGFloat(numOfMeats)
    }
    
    var body: some View {
        HStack(spacing: meatSpacing) {
            ForEach(0 ..< numOfMeats, id: \.self) { i in
                MeatIcon(fillAmount: calcFillAmt(for: i))
            }
        }
        .padding(Theme.md)
        .rotationEffect(.degrees(Double.random(in: -2...2)))
    }
    
    func calcFillAmt(for meatIndex: Int) -> CGFloat {
        let raw = (
          ( monster.energy - (CGFloat(meatIndex) * meatEnergyWorth) ) / meatEnergyWorth
        )
        return raw < 0 ? 0 : raw > 1 ? 1 : raw
    }
}

struct MeatIcon: View {
    var fillAmount: Double

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
                        }
                }
                Image("MeatOutline")
                    .resizable()
                    .scaledToFit()
            }

            .rotationEffect(Angle(degrees: Double.random(in: -7...7)))
    }
}

