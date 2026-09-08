import SwiftUI

/// 棋子色取 Tailwind CSS 调色板的 400 档:饱和度够、亮度一致,深色和浅色棋盘上都看得清。
enum PieceColor: String, CaseIterable, Identifiable {
    case red, orange, yellow, green, teal, blue, purple, pink

    var id: String { rawValue }

    var name: String {
        switch self {
        case .red: return "红色"
        case .orange: return "橙色"
        case .yellow: return "黄色"
        case .green: return "绿色"
        case .teal: return "青色"
        case .blue: return "蓝色"
        case .purple: return "紫色"
        case .pink: return "粉色"
        }
    }

    var color: Color {
        switch self {
        case .red: return Color(hex: 0xF87171)
        case .orange: return Color(hex: 0xFB923C)
        case .yellow: return Color(hex: 0xFBBF24)
        case .green: return Color(hex: 0x4ADE80)
        case .teal: return Color(hex: 0x2DD4BF)
        case .blue: return Color(hex: 0x38BDF8)
        case .purple: return Color(hex: 0xA78BFA)
        case .pink: return Color(hex: 0xF472B6)
        }
    }
}

/// 棋子色没手动选过(nil)就跟着棋盘默认走,换棋盘会自动换搭配;选过就固定不动。
struct Appearance: Equatable {
    var skin: BoardSkin
    var topChoice: PieceColor?
    var bottomChoice: PieceColor?

    var top: PieceColor { resolved.top }
    var bottom: PieceColor { resolved.bottom }

    private var resolved: (top: PieceColor, bottom: PieceColor) {
        var t = topChoice ?? skin.defaultTopPiece
        var b = bottomChoice ?? skin.defaultBottomPiece
        guard t == b else { return (t, b) }
        if topChoice == nil {
            t = PieceColor.allCases.first { $0 != b }!
        } else {
            b = PieceColor.allCases.first { $0 != t }!
        }
        return (t, b)
    }

    func color(for team: Team) -> Color { piece(for: team).color }
    func piece(for team: Team) -> PieceColor { team == .top ? top : bottom }
}
