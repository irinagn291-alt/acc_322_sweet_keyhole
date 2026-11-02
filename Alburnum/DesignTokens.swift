import SwiftUI
import UIKit

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #F4F6FA
    static let bg = Color(red: 0.956863, green: 0.964706, blue: 0.980392)
    static let bgHex = "#F4F6FA"
    /// #FDFEFE
    static let surface = Color(red: 0.992157, green: 0.996078, blue: 0.996078)
    static let surfaceHex = "#FDFEFE"
    /// #182239
    static let ink = Color(red: 0.094118, green: 0.133333, blue: 0.223529)
    static let inkHex = "#182239"
    /// #2855BD
    static let accent = Color(red: 0.156863, green: 0.333333, blue: 0.741176)
    static let accentHex = "#2855BD"
    /// #5E6C8D
    static let muted = Color(red: 0.368627, green: 0.423529, blue: 0.552941)
    static let mutedHex = "#5E6C8D"
    static let fontFamily = "Bradley Hand"

    static let bgUI = UIColor(red: 0.956863, green: 0.964706, blue: 0.980392, alpha: 1)
    static let surfaceUI = UIColor(red: 0.992157, green: 0.996078, blue: 0.996078, alpha: 1)
    static let inkUI = UIColor(red: 0.094118, green: 0.133333, blue: 0.223529, alpha: 1)
    static let accentUI = UIColor(red: 0.156863, green: 0.333333, blue: 0.741176, alpha: 1)
    static let mutedUI = UIColor(red: 0.368627, green: 0.423529, blue: 0.552941, alpha: 1)
}
