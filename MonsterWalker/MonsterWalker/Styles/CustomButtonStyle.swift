//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Theme.secondary)
            .foregroundStyle(Theme.primary)
            .cornerRadius(Theme.cornerRadius)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .font(Theme.indieflower)
    }
}

#Preview {
    Button("Hello World"){
        print("tapped")
    }.buttonStyle(CustomButtonStyle())
}
