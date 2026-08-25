import SwiftUI

enum BoardSkin: String, CaseIterable, Identifiable {
    case classic
    case light

    var id: String { rawValue }

    var name: String {
        switch self {
        case .classic: return "深绿"
        case .light: return "浅木"
        }
    }

    var boardBackground: [Color] {
        switch self {
        case .classic:
            return [Color(red: 0.14, green: 0.32, blue: 0.22), Color(red: 0.08, green: 0.22, blue: 0.15)]
        case .light:
            return [Color(red: 0.85, green: 0.72, blue: 0.55), Color(red: 0.72, green: 0.56, blue: 0.38)]
        }
    }

    var emptyCellColor: Color {
        switch self {
        case .classic: return .black.opacity(0.3)
        case .light: return .black.opacity(0.18)
        }
    }

    var topPieceColors: [Color] {
        switch self {
        case .classic: return [Color(red: 0.2, green: 0.78, blue: 0.32), Color(red: 0.08, green: 0.5, blue: 0.18)]
        case .light: return [Color(red: 0.35, green: 0.62, blue: 0.32), Color(red: 0.2, green: 0.42, blue: 0.2)]
        }
    }

    var bottomPieceColors: [Color] {
        switch self {
        case .classic: return [Color(red: 1.0, green: 0.62, blue: 0.1), Color(red: 0.88, green: 0.38, blue: 0.0)]
        case .light: return [Color(red: 0.85, green: 0.42, blue: 0.2), Color(red: 0.65, green: 0.28, blue: 0.1)]
        }
    }
}
