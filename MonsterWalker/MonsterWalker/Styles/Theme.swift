import SwiftUI

enum Theme {
    // MARK: Colors
    static let primary = SwiftUI.Color("PrimaryColor")
    static let secondary = SwiftUI.Color("SecondaryColor")
    static let background = SwiftUI.Color("BackgroundColor")
    static let textPrimary = SwiftUI.Color(.label)
    static let textSecondary = SwiftUI.Color(.secondaryLabel)

    // MARK: Spacing
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32

    // MARK: Typography
    static let indieflower = Font.custom("IndieFlower", size: 32)
    static let title = Font.system(size: 28, weight: .bold)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 12, weight: .light)
    
    // MARK: Geometry
    static let cornerRadius: CGFloat = 8
    
}
