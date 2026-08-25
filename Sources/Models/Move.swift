import Foundation

struct Move: Hashable {
    let from: Hex
    let to: Hex
    let path: [Hex] // 连跳时记录完整落点路径,用于走子动画
    let isJump: Bool
}

enum MoveGenerator {
    /// 单步移动 + 连跳,一次性返回某个棋子在当前棋盘上所有合法落点。
    static func availableMoves(for piece: Hex, on board: Board, jumpRule: JumpRule) -> [Move] {
        var moves: [Move] = []

        for n in piece.neighbors() where board.cells.contains(n) && board.piece(at: n) == nil {
            moves.append(Move(from: piece, to: n, path: [piece, n], isJump: false))
        }

        var visitedLandings: Set<Hex> = [piece]
        func explore(from: Hex, path: [Hex]) {
            for direction in 0..<6 {
                guard let landing = jumpTarget(from: from, direction: direction, on: board, jumpRule: jumpRule),
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

    /// 沿一个方向找"隔一子对称跳"的落点:被跳的子必须是这个方向上离起点最近的那颗子
    /// (跑道上不能有别的子挡着,这样才不会跳过第一颗子去跳第二颗)。标准规则只认跑道长度 0
    /// (紧邻),空格跳允许跑道更长。落点是以被跳的子为镜像中心、跟起点对称的那一格,
    /// 从那颗子到落点之间也必须全空(不能隔着别的子落地),这跟"聚吧""QQ 游戏"等平台的
    /// "空跳=单跳规则+隔一子对称跳"是同一个公式,标准跳只是跑道长度强制为 0 的特例。
    private static func jumpTarget(from: Hex, direction: Int, on board: Board, jumpRule: JumpRule) -> Hex? {
        var steps = 1
        while true {
            let cell = from.stepped(direction: direction, steps: steps)
            guard board.cells.contains(cell) else { return nil }
            if board.piece(at: cell) != nil { break }
            guard jumpRule == .allowEmpty else { return nil }
            steps += 1
        }

        let landingSteps = steps * 2
        for s in (steps + 1)...landingSteps {
            let c = from.stepped(direction: direction, steps: s)
            guard board.cells.contains(c), board.piece(at: c) == nil else { return nil }
        }
        return from.stepped(direction: direction, steps: landingSteps)
    }

    static func allMoves(for team: Team, on board: Board, jumpRule: JumpRule) -> [Move] {
        board.pieces(of: team).flatMap { availableMoves(for: $0, on: board, jumpRule: jumpRule) }
    }
}
