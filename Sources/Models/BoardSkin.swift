import SwiftUI

/// 皮肤配色全部取自知名开源配色方案(色值本身不受版权保护),不再是自己随手调的 RGB。
enum BoardSkin: String, CaseIterable, Identifiable {
    case catppuccinMocha
    case nord
    case dracula
    case solarizedDark
    case tokyoNight

    var id: String { rawValue }

    var name: String {
        switch self {
        case .catppuccinMocha: return "摩卡糖果"
        case .nord: return "北欧极光"
        case .dracula: return "德古拉"
        case .solarizedDark: return "复古暗调"
        case .tokyoNight: return "东京夜色"
        }
    }

    /// 来源:catppuccin.com / nordtheme.com / draculatheme.com /
    /// ethanschoonover.com/solarized / github.com/folke/tokyonight.nvim
    var boardBackground: [Color] {
        switch self {
        case .catppuccinMocha: return [Color(hex: 0x2A2A3F), Color(hex: 0x1E1E2E)]
        case .nord: return [Color(hex: 0x3B4252), Color(hex: 0x2E3440)]
        case .dracula: return [Color(hex: 0x343746), Color(hex: 0x282A36)]
        case .solarizedDark: return [Color(hex: 0x073642), Color(hex: 0x002B36)]
        case .tokyoNight: return [Color(hex: 0x24283B), Color(hex: 0x1B1E2D)]
        }
    }

    var emptyCellColor: Color { .white.opacity(0.12) }

    /// 每套配色里最协调的一对强调色,跟 boardBackground 同源,不是另外近似凑的。
    var topPieceColor: Color {
        switch self {
        case .catppuccinMocha: return Color(hex: 0xA6E3A1)
        case .nord: return Color(hex: 0xA3BE8C)
        case .dracula: return Color(hex: 0x50FA7B)
        case .solarizedDark: return Color(hex: 0x859900)
        case .tokyoNight: return Color(hex: 0x9ECE6A)
        }
    }

    var bottomPieceColor: Color {
        switch self {
        case .catppuccinMocha: return Color(hex: 0xFAB387)
        case .nord: return Color(hex: 0xD08770)
        case .dracula: return Color(hex: 0xFF79C6)
        case .solarizedDark: return Color(hex: 0xCB4B16)
        case .tokyoNight: return Color(hex: 0xF7768E)
        }
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
