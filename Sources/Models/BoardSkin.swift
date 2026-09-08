import SwiftUI

/// 棋盘底色。色值取自开源配色方案(Catppuccin / Nord / Dracula / Solarized / TokyoNight /
/// Tailwind CSS),不自己调 RGB。
enum BoardSkin: String, CaseIterable, Identifiable {
    case catppuccinMocha
    case nord
    case dracula
    case solarizedDark
    case tokyoNight
    case wood
    case cream
    case sakura
    case mint
    case ocean
    case forest

    var id: String { rawValue }

    var name: String {
        switch self {
        case .catppuccinMocha: return "摩卡糖果"
        case .nord: return "北欧极光"
        case .dracula: return "德古拉"
        case .solarizedDark: return "复古暗调"
        case .tokyoNight: return "东京夜色"
        case .wood: return "原木"
        case .cream: return "奶油"
        case .sakura: return "樱花"
        case .mint: return "薄荷"
        case .ocean: return "海洋"
        case .forest: return "森林"
        }
    }

    var boardBackground: [Color] {
        switch self {
        case .catppuccinMocha: return [Color(hex: 0x2A2A3F), Color(hex: 0x1E1E2E)]
        case .nord: return [Color(hex: 0x3B4252), Color(hex: 0x2E3440)]
        case .dracula: return [Color(hex: 0x343746), Color(hex: 0x282A36)]
        case .solarizedDark: return [Color(hex: 0x073642), Color(hex: 0x002B36)]
        case .tokyoNight: return [Color(hex: 0x24283B), Color(hex: 0x1B1E2D)]
        case .wood: return [Color(hex: 0x92400E), Color(hex: 0x451A03)]
        case .cream: return [Color(hex: 0xFEF3C7), Color(hex: 0xFDE68A)]
        case .sakura: return [Color(hex: 0xFCE7F3), Color(hex: 0xFBCFE8)]
        case .mint: return [Color(hex: 0xD1FAE5), Color(hex: 0xA7F3D0)]
        case .ocean: return [Color(hex: 0x1E3A8A), Color(hex: 0x172554)]
        case .forest: return [Color(hex: 0x166534), Color(hex: 0x052E16)]
        }
    }

    var isLight: Bool {
        switch self {
        case .cream, .sakura, .mint: return true
        default: return false
        }
    }

    var emptyCellColor: Color { isLight ? .black.opacity(0.10) : .white.opacity(0.12) }
    var emptyCellStroke: Color { isLight ? .black.opacity(0.08) : .white.opacity(0.08) }
    var highlightColor: Color { isLight ? Color(hex: 0x1E293B) : .white }

    var defaultTopPiece: PieceColor {
        switch self {
        case .catppuccinMocha, .nord, .solarizedDark, .tokyoNight, .dracula: return .green
        case .wood, .cream: return .blue
        case .sakura: return .purple
        case .mint: return .orange
        case .ocean: return .yellow
        case .forest: return .red
        }
    }

    var defaultBottomPiece: PieceColor {
        switch self {
        case .catppuccinMocha, .nord, .solarizedDark: return .orange
        case .dracula: return .pink
        case .tokyoNight: return .red
        case .wood, .cream: return .red
        case .sakura: return .teal
        case .mint: return .purple
        case .ocean: return .pink
        case .forest: return .yellow
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
