import SwiftUI

/// 迷你棋盘:六边形底 + 全部格点 + 双方起始区的棋子,跟当前皮肤实时同步,纯展示不可交互。
/// 首页和皮肤页共用,只是 spacing 不同。
struct DecorativeBoardPreview: View {
    let appearance: Appearance
    var spacing: CGFloat = 11

    private var cells: [Hex] {
        BoardLayout.allCells().sorted { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
    }

    private func point(for hex: Hex) -> CGPoint {
        CGPoint(x: CGFloat(hex.col) * (spacing / 2), y: CGFloat(hex.row) * (spacing * sqrt(3) / 2))
    }

    var body: some View {
        let points = cells.map(point(for:))
        let minX = points.map(\.x).min() ?? 0, maxX = points.map(\.x).max() ?? 0
        let minY = points.map(\.y).min() ?? 0, maxY = points.map(\.y).max() ?? 0
        let center = CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
        let maxDist = points.map { hypot($0.x - center.x, $0.y - center.y) }.max() ?? 0
        let radius = maxDist + spacing * 0.85
        let size = CGSize(width: radius * sqrt(3), height: radius * 2)
        let pieces = BoardLayout.startCells(for: .top).map { ($0, appearance.top.color) }
            + BoardLayout.startCells(for: .bottom).map { ($0, appearance.bottom.color) }

        ZStack {
            BoardHexagon()
                .fill(
                    LinearGradient(
                        colors: appearance.skin.boardBackground,
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(0.35), radius: 8, y: 3)

            ForEach(cells, id: \.self) { hex in
                let p = point(for: hex)
                Circle()
                    .fill(appearance.skin.emptyCellColor)
                    .frame(width: spacing * 0.45, height: spacing * 0.45)
                    .position(x: p.x - center.x + size.width / 2, y: p.y - center.y + size.height / 2)
            }

            ForEach(pieces, id: \.0) { hex, color in
                let p = point(for: hex)
                Circle()
                    .fill(color)
                    .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                    .frame(width: spacing * 0.8, height: spacing * 0.8)
                    .position(x: p.x - center.x + size.width / 2, y: p.y - center.y + size.height / 2)
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview {
    DecorativeBoardPreview(appearance: Appearance(skin: .catppuccinMocha))
        .padding(40)
        .background(Color(red: 0.08, green: 0.12, blue: 0.18))
}
