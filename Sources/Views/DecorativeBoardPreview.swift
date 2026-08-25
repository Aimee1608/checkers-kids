import SwiftUI

/// 首页顶部的装饰性小棋盘:完整六角星轮廓 + 几颗悬浮彩色棋子,纯展示不可交互。
struct DecorativeBoardPreview: View {
    private let spacing: CGFloat = 11
    private let dotSize: CGFloat = 5

    private var cells: [Hex] {
        BoardLayout.allCells().sorted { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
    }

    private func point(for hex: Hex) -> CGPoint {
        CGPoint(x: CGFloat(hex.col) * (spacing / 2), y: CGFloat(hex.row) * (spacing * sqrt(3) / 2))
    }

    private var bounds: (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        let points = cells.map(point(for:))
        return (
            points.map(\.x).min() ?? 0, points.map(\.x).max() ?? 0,
            points.map(\.y).min() ?? 0, points.map(\.y).max() ?? 0
        )
    }

    private let floatingMarbles: [(hex: Hex, color: Color)] = [
        (Hex(col: 0, row: 6), .orange),
        (Hex(col: -6, row: 8), .blue),
        (Hex(col: 6, row: 8), .purple),
        (Hex(col: -3, row: 11), .pink),
        (Hex(col: 3, row: 11), .mint),
    ]

    var body: some View {
        let b = bounds
        let width = b.maxX - b.minX + dotSize * 2
        let height = b.maxY - b.minY + dotSize * 2

        ZStack {
            ForEach(cells, id: \.self) { hex in
                let p = point(for: hex)
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: dotSize, height: dotSize)
                    .position(x: p.x - b.minX + dotSize, y: p.y - b.minY + dotSize)
            }
            ForEach(Array(floatingMarbles.enumerated()), id: \.offset) { _, marble in
                let p = point(for: marble.hex)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [marble.color.opacity(0.95), marble.color.opacity(0.6)],
                            center: .topLeading, startRadius: 1, endRadius: 20
                        )
                    )
                    .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1))
                    .shadow(color: marble.color.opacity(0.5), radius: 6, y: 3)
                    .frame(width: 30, height: 30)
                    .position(x: p.x - b.minX + dotSize, y: p.y - b.minY + dotSize)
            }
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    DecorativeBoardPreview()
        .padding(40)
        .background(Color(red: 0.08, green: 0.12, blue: 0.18))
}
