import SwiftUI

enum Theme {
    static let bg = Color.black
    static let surface = Color(red: 0.071, green: 0.067, blue: 0.063)
    static let surface2 = Color(red: 0.106, green: 0.098, blue: 0.090)
    static let line = Color(red: 0.165, green: 0.149, blue: 0.133)
    static let fg = Color(red: 0.953, green: 0.933, blue: 0.902)
    static let muted = Color(red: 0.561, green: 0.529, blue: 0.486)
}

enum AccentChoice: String, CaseIterable, Identifiable {
    case amber, mint, lilac, coral
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .amber: return Color(red: 0.914, green: 0.706, blue: 0.416)
        case .mint:  return Color(red: 0.498, green: 0.820, blue: 0.757)
        case .lilac: return Color(red: 0.776, green: 0.651, blue: 1.0)
        case .coral: return Color(red: 1.0, green: 0.561, blue: 0.478)
        }
    }
}
