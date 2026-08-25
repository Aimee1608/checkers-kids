import Foundation
import Combine
import SwiftUI

enum GameMode {
    case vsAI
    case local // 双人本地对战(面对面传着玩),两边都是人手动点
}

@MainActor
final class GameEngine: ObservableObject {
    @Published private(set) var board = Board()
    @Published private(set) var currentTurn: Team = .bottom // 小朋友执 bottom 先走
    @Published private(set) var winner: Team?
    @Published var selectedPiece: Hex?
    @Published private(set) var legalDestinations: [Hex] = []
    @Published private(set) var isAnimating = false
    @Published private(set) var moveCount = 0

    let mode: GameMode
    let humanTeam: Team = .bottom
    let aiTeam: Team = .top
    let aiDifficulty: AIDifficulty // 开局前在首页选好,对局中不再改

    /// 中途 reset() 会让正在跑的 AI 思考/连跳动画作废,靠这个代数号识别"这次异步任务是不是已经过期了"。
    private var generation = 0

    init(mode: GameMode, aiDifficulty: AIDifficulty = .medium) {
        self.mode = mode
        self.aiDifficulty = aiDifficulty
    }

    var isInteractive: Bool {
        guard winner == nil, !isAnimating else { return false }
        return mode == .local || currentTurn == humanTeam
    }

    func select(_ hex: Hex) {
        guard isInteractive else { return }

        if let selected = selectedPiece, legalDestinations.contains(hex) {
            let moves = MoveGenerator.availableMoves(for: selected, on: board)
            if let move = moves.first(where: { $0.to == hex }) {
                perform(move)
            }
            return
        }

        guard board.piece(at: hex)?.team == currentTurn else {
            selectedPiece = nil
            legalDestinations = []
            return
        }
        selectedPiece = hex
        legalDestinations = MoveGenerator.availableMoves(for: hex, on: board).map(\.to)
        Haptics.select()
    }

    func perform(_ move: Move) {
        selectedPiece = nil
        legalDestinations = []
        moveCount += 1
        Haptics.move()
        animateAlongPath(move) { [weak self] in
            guard let self else { return }
            if self.board.isWon(by: self.currentTurn) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                    self.winner = self.currentTurn
                }
                Haptics.win()
                return
            }
            self.currentTurn = self.currentTurn.opponent
            if self.mode == .vsAI && self.currentTurn == self.aiTeam {
                self.requestAIMove()
            }
        }
    }

    /// 按 move.path 逐格动画,连跳时一跳一跳地走给小朋友看清楚,不是瞬移到终点。
    private func animateAlongPath(_ move: Move, completion: @escaping () -> Void) {
        let myGeneration = generation
        guard move.path.count > 2 else {
            withAnimation(.easeInOut(duration: 0.3)) { board.apply(move) }
            completion()
            return
        }
        isAnimating = true
        Task {
            for i in 1..<move.path.count {
                let step = Move(from: move.path[i - 1], to: move.path[i], path: [], isJump: move.isJump)
                await MainActor.run {
                    guard self.generation == myGeneration else { return }
                    withAnimation(.easeInOut(duration: 0.22)) { self.board.apply(step) }
                }
                try? await Task.sleep(nanoseconds: 260_000_000)
            }
            await MainActor.run {
                guard self.generation == myGeneration else { return }
                self.isAnimating = false
                completion()
            }
        }
    }

    func requestAIMove() {
        let snapshot = board
        let team = aiTeam
        let difficulty = aiDifficulty
        let myGeneration = generation
        Task {
            // 先"想"一下,别一变成电脑回合就秒下,小朋友根本反应不过来。
            try? await Task.sleep(nanoseconds: 500_000_000)
            let move = await CheckersAI.bestMove(for: team, on: snapshot, difficulty: difficulty)
            await MainActor.run {
                guard self.generation == myGeneration,
                      let move, self.currentTurn == team, self.winner == nil else { return }
                self.perform(move)
            }
        }
    }

    /// 中途想重开这一局,或者赢了之后再来一局,都走这个。
    func reset() {
        generation += 1
        board = Board()
        currentTurn = .bottom
        winner = nil
        selectedPiece = nil
        legalDestinations = []
        isAnimating = false
        moveCount = 0
    }
}
