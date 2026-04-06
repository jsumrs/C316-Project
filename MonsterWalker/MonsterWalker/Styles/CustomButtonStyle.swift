//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.indieflower)
            .foregroundStyle(.black)
            .padding(.horizontal, Theme.xl * 3)
            .padding(.vertical, Theme.md)
            .background(Theme.secondary)
            .opacity(configuration.isPressed ? 1.0 : 0.7)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                Image("SketchBorder")
                    .resizable()
            )
            .rotationEffect(.degrees(Double.random(in: 0 ... 2)))
    }
}

#Preview {
    Button("Hello World"){
        print("tapped")
    }.buttonStyle(CustomButtonStyle())
}
