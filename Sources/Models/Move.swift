import Foundation

struct Move: Hashable {
    let from: Hex
    let to: Hex
    let path: [Hex] // 连跳时记录完整落点路径,用于走子动画
    let isJump: Bool
}

enum MoveGenerator {
    /// 单步移动 + 连跳,一次性返回某个棋子在当前棋盘上所有合法落点。
    static func availableMoves(for piece: Hex, on board: Board) -> [Move] {
        var moves: [Move] = []

        for n in piece.neighbors() where board.cells.contains(n) && board.piece(at: n) == nil {
            moves.append(Move(from: piece, to: n, path: [piece, n], isJump: false))
        }

        var visitedLandings: Set<Hex> = [piece]
        func explore(from: Hex, path: [Hex]) {
            for (direction, n) in from.neighbors().enumerated() {
                guard board.cells.contains(n), board.piece(at: n) != nil else { continue }
                let landing = from.jumpLanding(direction: direction)
                guard board.cells.contains(landing),
                      board.piece(at: landing) == nil,
                      !visitedLandings.contains(landing) else { continue }
                visitedLandings.insert(landing)
                let newPath = path + [landing]
                moves.append(Move(from: piece, to: landing, path: newPath, isJump: true))
                explore(from: landing, path: newPath)
            }
        }
        explore(from: piece, path: [piece])

        return moves
    }

    static func allMoves(for team: Team, on board: Board) -> [Move] {
        board.pieces(of: team).flatMap { availableMoves(for: $0, on: board) }
    }
}
