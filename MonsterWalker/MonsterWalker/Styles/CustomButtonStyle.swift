//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.indieflower)
            .foregroundStyle(Theme.primary)
            .padding(.horizontal, Theme.xl)
            .padding(.vertical, Theme.md)
            .background(Theme.secondary)
            .opacity(configuration.isPressed ? 1.0 : 0.7)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                Image("SketchBorder")
                    .resizable()
            )
            .rotationEffect(.degrees(Double.random(in: -2...2)))
    }
}

#Preview {
    Button("Hello World"){
        print("tapped")
    }.buttonStyle(CustomButtonStyle())
}
