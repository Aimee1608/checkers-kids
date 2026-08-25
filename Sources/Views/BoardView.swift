import SwiftUI

struct BoardView: View {
    @ObservedObject var engine: GameEngine
    let maxWidth: CGFloat
    var skin: BoardSkin = .classic

    var body: some View {
        let spacing = calcSpacing(maxWidth: maxWidth)
        let pegSize = spacing * 0.78
        let points = sortedCells.map { point(for: $0, spacing: spacing) }
        let center = centroid(of: points)
        let diameter = discDiameter(points: points, center: center, pegSize: pegSize)
        let half = diameter / 2

        ZStack {
            // 棋盘做成圆盘,不是方板——直径按"到几何中心最远的格子"动态算,
            // 保证六个尖角不会被圆边裁掉,格子/棋子的坐标也相应地以圆心为原点重新定位。
            Circle()
                .fill(
                    LinearGradient(
                        colors: skin.boardBackground,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: diameter, height: diameter)
                .shadow(color: .black.opacity(0.35), radius: 10, y: 4)

            // 格子层:固定位置,负责点击和空格/落点提示,不随棋子移动。
            ForEach(sortedCells, id: \.self) { hex in
                let p = point(for: hex, spacing: spacing)
                cellButton(for: hex, pegSize: pegSize)
                    .position(x: p.x - center.x + half, y: p.y - center.y + half)
            }

            // 棋子层:按 piece.id 单独 track,棋子移动时坐标平滑过渡,不是瞬移。
            ForEach(Array(engine.board.pieces), id: \.value.id) { hex, piece in
                let p = point(for: hex, spacing: spacing)
                pieceView(for: piece, pegSize: pegSize, isSelected: engine.selectedPiece == hex)
                    .position(x: p.x - center.x + half, y: p.y - center.y + half)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: diameter, height: diameter)
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

    private func centroid(of points: [CGPoint]) -> CGPoint {
        let minX = points.map(\.x).min() ?? 0, maxX = points.map(\.x).max() ?? 0
        let minY = points.map(\.y).min() ?? 0, maxY = points.map(\.y).max() ?? 0
        return CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
    }

    /// 圆盘直径 = 2×(圆心到最远格子的欧氏距离) + 一点边距,六个尖角旋转对称,
    /// 到圆心距离本来就相等,这个半径天然就是外接圆半径。
    private func discDiameter(points: [CGPoint], center: CGPoint, pegSize: CGFloat) -> CGFloat {
        let maxDist = points.map { hypot($0.x - center.x, $0.y - center.y) }.max() ?? 0
        return maxDist * 2 + pegSize * 2.4
    }

    /// 根据屏幕可用宽度动态计算格子间距，确保棋盘不超出屏幕、也不会在大屏(iPad)上小得可怜。
    private func calcSpacing(maxWidth: CGFloat) -> CGFloat {
        // 最宽行有 13 个格子(第 8 行),左右各留 pegSize 的边距
        // 最宽行宽度 = (13 - 1) * spacing / 2 * 2 + pegSize * 2 = 12 * spacing + spacing * 0.78 * 2
        // 解方程: spacing * (12 + 1.56) = maxWidth - padding
        let padding: CGFloat = 12
        let available = maxWidth - padding * 2
        let spacing = available / (12 + 1.56)
        return min(max(22, spacing), 80)
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
                    .fill(skin.emptyCellColor)
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
        let imageName = piece.team == .top ? skin.topPieceImageName : skin.bottomPieceImageName

        ZStack {
            // 宝石贴图画布是正方形,但宝石本体画得又扁又窄,scaledToFill 只能让
            // 画布填满方框、宝石本体还是撑不满——裁成圆之后中间会露棋盘底色。
            // 额外放大一倍多把宝石本体撑到圆框外面,裁剪掉画布空白和宝石两头尖角。
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: pegSize * 0.82, height: pegSize * 0.82)
                .scaleEffect(2.1)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.35), radius: 3, y: 2)

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
