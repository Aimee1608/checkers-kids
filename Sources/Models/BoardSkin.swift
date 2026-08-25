import SwiftUI

enum BoardSkin: String, CaseIterable, Identifiable {
    case classic
    case light
    case jelly
    case diamond
    case planet
    case rainbow

    var id: String { rawValue }

    var name: String {
        switch self {
        case .classic: return "深绿"
        case .light: return "浅木"
        case .jelly: return "果冻"
        case .diamond: return "钻石"
        case .planet: return "星球"
        case .rainbow: return "炫彩"
        }
    }

    var boardBackground: [Color] {
        switch self {
        case .classic:
            return [Color(red: 0.14, green: 0.32, blue: 0.22), Color(red: 0.08, green: 0.22, blue: 0.15)]
        case .light:
            return [Color(red: 0.85, green: 0.72, blue: 0.55), Color(red: 0.72, green: 0.56, blue: 0.38)]
        case .jelly:
            return [Color(red: 0.96, green: 0.78, blue: 0.87), Color(red: 0.85, green: 0.66, blue: 0.92)]
        case .diamond:
            return [Color(red: 0.78, green: 0.9, blue: 0.97), Color(red: 0.55, green: 0.76, blue: 0.9)]
        case .planet:
            return [Color(red: 0.12, green: 0.08, blue: 0.26), Color(red: 0.05, green: 0.03, blue: 0.15)]
        case .rainbow:
            return [Color(red: 0.55, green: 0.25, blue: 0.75), Color(red: 0.32, green: 0.14, blue: 0.52)]
        }
    }

    var emptyCellColor: Color {
        switch self {
        case .classic: return .black.opacity(0.3)
        case .light: return .black.opacity(0.18)
        case .jelly: return .black.opacity(0.14)
        case .diamond: return .black.opacity(0.14)
        case .planet: return .white.opacity(0.12)
        case .rainbow: return .black.opacity(0.22)
        }
    }

    var topPieceColors: [Color] {
        switch self {
        case .classic: return [Color(red: 0.2, green: 0.78, blue: 0.32), Color(red: 0.08, green: 0.5, blue: 0.18)]
        case .light: return [Color(red: 0.35, green: 0.62, blue: 0.32), Color(red: 0.2, green: 0.42, blue: 0.2)]
        case .jelly: return [Color(red: 0.35, green: 0.88, blue: 0.78), Color(red: 0.15, green: 0.62, blue: 0.56)]
        case .diamond: return [Color(red: 0.3, green: 0.58, blue: 0.98), Color(red: 0.12, green: 0.35, blue: 0.78)]
        case .planet: return [Color(red: 0.25, green: 0.88, blue: 0.68), Color(red: 0.08, green: 0.58, blue: 0.42)]
        case .rainbow: return [Color(red: 0.58, green: 0.95, blue: 0.28), Color(red: 0.38, green: 0.75, blue: 0.12)]
        }
    }

    var bottomPieceColors: [Color] {
        switch self {
        case .classic: return [Color(red: 1.0, green: 0.62, blue: 0.1), Color(red: 0.88, green: 0.38, blue: 0.0)]
        case .light: return [Color(red: 0.85, green: 0.42, blue: 0.2), Color(red: 0.65, green: 0.28, blue: 0.1)]
        case .jelly: return [Color(red: 1.0, green: 0.48, blue: 0.68), Color(red: 0.88, green: 0.22, blue: 0.48)]
        case .diamond: return [Color(red: 0.78, green: 0.72, blue: 0.95), Color(red: 0.58, green: 0.5, blue: 0.8)]
        case .planet: return [Color(red: 1.0, green: 0.48, blue: 0.28), Color(red: 0.8, green: 0.22, blue: 0.1)]
        case .rainbow: return [Color(red: 1.0, green: 0.28, blue: 0.68), Color(red: 0.85, green: 0.1, blue: 0.5)]
        }
    }

    /// 棋子贴图(CC0 授权,来自 opengameart.org 的 Gem Stones UI Sprites),
    /// 换掉纯 SwiftUI 渐变圆,棋子看起来更像颗真宝石。
    var topPieceImageName: String {
        switch self {
        case .classic: return "gem_green"
        case .light: return "gem_green"
        case .jelly: return "gem_teal"
        case .diamond: return "gem_ice"
        case .planet: return "gem_emerald"
        case .rainbow: return "gem_yellowgreen"
        }
    }

    var bottomPieceImageName: String {
        switch self {
        case .classic: return "gem_orange"
        case .light: return "gem_rust"
        case .jelly: return "gem_magenta"
        case .diamond: return "gem_purple"
        case .planet: return "gem_red"
        case .rainbow: return "gem_pink"
        }
    }
}
