import SwiftUI

/// 顶点朝上的正六边形,六个顶点正好落在六角星的六个尖角上——六角星本身就是
/// 上下尖、左右扁,用外接圆罩它会白白多出 15% 的宽度(圆得画到能容下上下尖角
/// 的直径,横向就撑得过宽了),换成这个六边形宽度直接收窄到内容本身的跨度。
struct BoardHexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = rect.height / 2
        var p = Path()
        for i in 0..<6 {
            let angle = Angle(degrees: Double(i) * 60 - 90).radians
            let v = CGPoint(x: c.x + r * cos(angle), y: c.y + r * sin(angle))
            i == 0 ? p.move(to: v) : p.addLine(to: v)
        }
        p.closeSubpath()
        return p
    }
}

struct BoardView: View {
    @ObservedObject var engine: GameEngine
    let maxWidth: CGFloat
    var skin: BoardSkin = .catppuccinMocha

    /// 邻格中心距恰好等于 spacing,所以直径 ≤ spacing 的圆形点击区互不重叠。
    /// 取 0.95 让触摸区几乎铺满格子,小朋友手指点得准。
    private static let tapRatio: CGFloat = 0.95
    private static let emptyDotRatio: CGFloat = 0.62
    private static let pieceRatio: CGFloat = 0.82

    var body: some View {
        let spacing = calcSpacing(maxWidth: maxWidth)
        let pegSize = spacing * Self.tapRatio
        let points = sortedCells.map { point(for: $0, spacing: spacing) }
        let center = centroid(of: points)
        let radius = hexRadius(points: points, center: center, pegSize: pegSize)
        let size = hexSize(radius: radius)

        ZStack {
            BoardHexagon()
                .fill(
                    LinearGradient(
                        colors: skin.boardBackground,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(0.35), radius: 10, y: 4)

            // 格子层:固定位置,负责点击和空格/落点提示,不随棋子移动。
            ForEach(sortedCells, id: \.self) { hex in
                let p = point(for: hex, spacing: spacing)
                cellButton(for: hex, pegSize: pegSize)
                    .position(
                        x: p.x - center.x + size.width / 2,
                        y: p.y - center.y + size.height / 2
                    )
            }

            // 棋子层:按 piece.id 单独 track,棋子移动时坐标平滑过渡,不是瞬移。
            ForEach(Array(engine.board.pieces), id: \.value.id) { hex, piece in
                let p = point(for: hex, spacing: spacing)
                pieceView(for: piece, pegSize: pegSize, isSelected: engine.selectedPiece == hex)
                    .position(
                        x: p.x - center.x + size.width / 2,
                        y: p.y - center.y + size.height / 2
                    )
                    .allowsHitTesting(false)
            }
        }
        .frame(width: size.width, height: size.height)
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

    /// 六个尖角旋转对称,到中心距离本来就相等,这个距离就是六边形的外接圆半径。
    private func hexRadius(points: [CGPoint], center: CGPoint, pegSize: CGFloat) -> CGFloat {
        let maxDist = points.map { hypot($0.x - center.x, $0.y - center.y) }.max() ?? 0
        return maxDist + pegSize * 0.75
    }

    /// 顶点朝上的正六边形:高 = 2r(顶点到顶点),宽 = √3·r(边到边)。
    private func hexSize(radius: CGFloat) -> CGSize {
        CGSize(width: radius * sqrt(3), height: radius * 2)
    }

    /// 根据屏幕可用宽度动态计算格子间距。约束是六边形的**宽度**(√3·r),不是高度——
    /// 六角星上下比左右长,高度方向由外层 ScrollView 兜着。用真实的 hexRadius 公式在
    /// 参考间距下跑一遍再反解,不猜系数(以前手推近似公式算错过,棋盘右边被裁出屏幕)。
    private func calcSpacing(maxWidth: CGFloat) -> CGFloat {
        let padding: CGFloat = 6
        let available = maxWidth - padding * 2

        let referenceSpacing: CGFloat = 100
        let refPoints = sortedCells.map { point(for: $0, spacing: referenceSpacing) }
        let refCenter = centroid(of: refPoints)
        let refRadius = hexRadius(
            points: refPoints, center: refCenter, pegSize: referenceSpacing * Self.tapRatio
        )
        let refWidth = hexSize(radius: refRadius).width

        let spacing = available * referenceSpacing / refWidth
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
                    .frame(width: pegSize * Self.emptyDotRatio, height: pegSize * Self.emptyDotRatio)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                if !hasPiece && isDestination {
                    Circle()
                        .fill(Color.yellow.opacity(0.7))
                        .frame(width: pegSize * 0.34, height: pegSize * 0.34)
                        .shadow(color: .yellow.opacity(0.6), radius: 4)
                }
            }
            .frame(width: pegSize, height: pegSize)
            // 圆形而不是方形:方形触摸区在斜向邻格之间会互相重叠(斜邻格的横向间距只有
            // spacing/2),圆形按中心距判定,直径不超过 spacing 就一定不抢彼此的点击。
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!engine.isInteractive)
        .accessibilityIdentifier("peg_\(hex.col)_\(hex.row)")
    }

    @ViewBuilder
    private func pieceView(for piece: Piece, pegSize: CGFloat, isSelected: Bool) -> some View {
        let color = piece.team == .top ? skin.topPieceColor : skin.bottomPieceColor
        let d = pegSize * Self.pieceRatio

        ZStack {
            Circle()
                .fill(color)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.55), Color.white.opacity(0)],
                                center: UnitPoint(x: 0.32, y: 0.28),
                                startRadius: 0,
                                endRadius: d * 0.6
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                )
                .frame(width: d, height: d)
                .shadow(color: .black.opacity(0.35), radius: 3, y: 2)

            if isSelected {
                Circle()
                    .stroke(Color.yellow, lineWidth: 3)
                    .frame(width: d * 1.12, height: d * 1.12)
                    .shadow(color: .yellow.opacity(0.7), radius: 5)
            }
        }
        .frame(width: pegSize, height: pegSize)
    }
}
