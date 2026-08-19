import SwiftUI

struct BoardView: View {
    @ObservedObject var engine: GameEngine

    private let pegSpacing: CGFloat = 34
    private var pegSize: CGFloat { pegSpacing * 0.78 }

    private var sortedCells: [Hex] {
        engine.board.cells.sorted { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }
    }

    private func point(for hex: Hex) -> CGPoint {
        CGPoint(
            x: CGFloat(hex.col) * (pegSpacing / 2),
            y: CGFloat(hex.row) * (pegSpacing * sqrt(3) / 2)
        )
    }

    private var bounds: (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        let points = sortedCells.map(point(for:))
        return (
            points.map(\.x).min() ?? 0,
            points.map(\.x).max() ?? 0,
            points.map(\.y).min() ?? 0,
            points.map(\.y).max() ?? 0
        )
    }

    var body: some View {
        let b = bounds
        let width = b.maxX - b.minX + pegSize * 2
        let height = b.maxY - b.minY + pegSize * 2

        ZStack {
            ForEach(sortedCells, id: \.self) { hex in
                let p = point(for: hex)
                pegView(for: hex)
                    .position(x: p.x - b.minX + pegSize, y: p.y - b.minY + pegSize)
            }
        }
        .frame(width: width, height: height)
    }

    @ViewBuilder
    private func pegView(for hex: Hex) -> some View {
        let team = engine.board.piece(at: hex)
        let isSelected = engine.selectedPiece == hex
        let isDestination = engine.legalDestinations.contains(hex)

        Button {
            engine.select(hex)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.12))
                    .frame(width: pegSize, height: pegSize)

                if let team {
                    Circle()
                        .fill(color(for: team))
                        .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1.5))
                        .shadow(radius: 1.5, y: 1)
                        .frame(width: pegSize * 0.86, height: pegSize * 0.86)
                        .overlay(
                            Circle()
                                .stroke(Color.yellow, lineWidth: 3)
                                .opacity(isSelected ? 1 : 0)
                        )
                } else if isDestination {
                    Circle()
                        .fill(Color.green.opacity(0.55))
                        .frame(width: pegSize * 0.4, height: pegSize * 0.4)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(engine.currentTurn != engine.humanTeam || engine.winner != nil)
    }

    private func color(for team: Team) -> Color {
        team == .top ? .green : .orange
    }
}
