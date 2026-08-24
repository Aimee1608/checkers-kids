import SwiftUI

struct BoardView: View {
    @ObservedObject var engine: GameEngine
    let maxWidth: CGFloat

    var body: some View {
        let spacing = calcSpacing(maxWidth: maxWidth)
        let pegSize = spacing * 0.78
        let b = bounds(spacing: spacing)
        let width = b.maxX - b.minX + pegSize * 2
        let height = b.maxY - b.minY + pegSize * 2

        ZStack {
            // Board background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.14, green: 0.32, blue: 0.22),
                            Color(red: 0.08, green: 0.22, blue: 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width, height: height)
                .shadow(color: .black.opacity(0.35), radius: 10, y: 4)

            // 格子层:固定位置,负责点击和空格/落点提示,不随棋子移动。
            ForEach(sortedCells, id: \.self) { hex in
                let p = point(for: hex, spacing: spacing)
                cellButton(for: hex, pegSize: pegSize)
                    .position(x: p.x - b.minX + pegSize, y: p.y - b.minY + pegSize)
            }

            // 棋子层:按 piece.id 单独 track,棋子移动时坐标平滑过渡,不是瞬移。
            ForEach(Array(engine.board.pieces), id: \.value.id) { hex, piece in
                let p = point(for: hex, spacing: spacing)
                pieceView(for: piece, pegSize: pegSize, isSelected: engine.selectedPiece == hex)
                    .position(x: p.x - b.minX + pegSize, y: p.y - b.minY + pegSize)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: height)
    }

    private var sortedCells: [Hex] {
        engine.board.cells.sorted { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
    }

    private func point(for hex: Hex, spacing: CGFloat) -> CGPoint {
        CGPoint(
            x: CGFloat(hex.col) * (spacing / 2),
            y: CGFloat(hex.row) * (spacing * sqrt(3) / 2)
        )
    }

    private func bounds(spacing: CGFloat) -> (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        let points = sortedCells.map { point(for: $0, spacing: spacing) }
        return (
            points.map(\.x).min() ?? 0,
            points.map(\.x).max() ?? 0,
            points.map(\.y).min() ?? 0,
            points.map(\.y).max() ?? 0
        )
    }

    /// 根据屏幕可用宽度动态计算格子间距，确保棋盘不超出屏幕。
    private func calcSpacing(maxWidth: CGFloat) -> CGFloat {
        // 最宽行有 13 个格子(第 8 行),左右各留 pegSize 的边距
        // 最宽行宽度 = (13 - 1) * spacing / 2 * 2 + pegSize * 2 = 12 * spacing + spacing * 0.78 * 2
        // 解方程: spacing * (12 + 1.56) = maxWidth - padding
        let padding: CGFloat = 12
        let available = maxWidth - padding * 2
        let spacing = available / (12 + 1.56)
        return min(max(22, spacing), 36)
    }

    @ViewBuilder
    private func cellButton(for hex: Hex, pegSize: CGFloat) -> some View {
        let isDestination = engine.legalDestinations.contains(hex)
        let hasPiece = engine.board.piece(at: hex) != nil

        Button {
            engine.select(hex)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: pegSize * 0.65, height: pegSize * 0.65)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                if !hasPiece && isDestination {
                    Circle()
                        .fill(Color.yellow.opacity(0.7))
                        .frame(width: pegSize * 0.35, height: pegSize * 0.35)
                        .shadow(color: .yellow.opacity(0.6), radius: 4)
                }
            }
            .frame(width: pegSize, height: pegSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!engine.isInteractive)
        .accessibilityIdentifier("peg_\(hex.col)_\(hex.row)")
    }

    @ViewBuilder
    private func pieceView(for piece: Piece, pegSize: CGFloat, isSelected: Bool) -> some View {
        let colors = piece.team == .top
            ? [Color(red: 0.2, green: 0.78, blue: 0.32), Color(red: 0.08, green: 0.5, blue: 0.18)]
            : [Color(red: 1.0, green: 0.62, blue: 0.1), Color(red: 0.88, green: 0.38, blue: 0.0)]

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: colors,
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: pegSize * 0.6
                    )
                )
                .frame(width: pegSize * 0.82, height: pegSize * 0.82)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.35), radius: 3, y: 2)

            // Highlight / shine
            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: pegSize * 0.28, height: pegSize * 0.28)
                .offset(x: -pegSize * 0.12, y: -pegSize * 0.12)

            if isSelected {
                Circle()
                    .stroke(Color.yellow, lineWidth: 3)
                    .frame(width: pegSize * 0.92, height: pegSize * 0.92)
                    .shadow(color: .yellow.opacity(0.7), radius: 5)
            }
        }
        .frame(width: pegSize, height: pegSize)
    }
}
