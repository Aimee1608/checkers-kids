import Foundation

enum AIDifficulty: Int, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3

    var searchDepth: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

enum CheckersAI {
    /// 在后台线程跑 minimax,避免卡主线程/UI。
    static func bestMove(for team: Team, on board: Board, difficulty: AIDifficulty) async -> Move? {
        await Task.detached(priority: .userInitiated) {
            let moves = MoveGenerator.allMoves(for: team, on: board)
            guard !moves.isEmpty else { return nil }

            var bestScore = Int.min
            var bestMoves: [Move] = []
            var alpha = Int.min
            let beta = Int.max

            for move in moves {
                let nextBoard = board.applying(move)
                let score = minimax(
                    board: nextBoard,
                    depth: difficulty.searchDepth - 1,
                    maximizing: false,
                    aiTeam: team,
                    alpha: alpha,
                    beta: beta
                )
                if score > bestScore {
                    bestScore = score
                    bestMoves = [move]
                    alpha = max(alpha, score)
                } else if score == bestScore {
                    bestMoves.append(move)
                }
            }
            // 同分里随机挑一个,棋风不至于每次都完全一样。
            return bestMoves.randomElement()
        }.value
    }

    private static func minimax(
        board: Board,
        depth: Int,
        maximizing: Bool,
        aiTeam: Team,
        alpha: Int,
        beta: Int
    ) -> Int {
        let team = maximizing ? aiTeam : aiTeam.opponent

        if board.isWon(by: aiTeam) { return 100_000 + depth }
        if board.isWon(by: aiTeam.opponent) { return -100_000 - depth }
        if depth == 0 { return evaluate(board: board, for: aiTeam) }

        let moves = MoveGenerator.allMoves(for: team, on: board)
        guard !moves.isEmpty else { return evaluate(board: board, for: aiTeam) }

        var alpha = alpha
        var beta = beta

        if maximizing {
            var best = Int.min
            for move in moves {
                let score = minimax(
                    board: board.applying(move), depth: depth - 1, maximizing: false,
                    aiTeam: aiTeam, alpha: alpha, beta: beta
                )
                best = max(best, score)
                alpha = max(alpha, best)
                if beta <= alpha { break }
            }
            return best
        } else {
            var best = Int.max
            for move in moves {
                let score = minimax(
                    board: board.applying(move), depth: depth - 1, maximizing: true,
                    aiTeam: aiTeam, alpha: alpha, beta: beta
                )
                best = min(best, score)
                beta = min(beta, best)
                if beta <= alpha { break }
            }
            return best
        }
    }

    /// 用棋子到目标区的"行进度"打分:己方越靠近目标越好,对方越靠近目标越要防。
    private static func evaluate(board: Board, for aiTeam: Team) -> Int {
        func progress(_ hex: Hex, team: Team) -> Int {
            team == .top ? hex.row : (BoardLayout.rowCount - 1 - hex.row)
        }
        let own = board.pieces(of: aiTeam).reduce(0) { $0 + progress($1, team: aiTeam) }
        let opp = board.pieces(of: aiTeam.opponent).reduce(0) { $0 + progress($1, team: aiTeam.opponent) }
        return own - opp
    }
}
