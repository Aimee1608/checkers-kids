import Foundation
import Combine

@MainActor
final class GameEngine: ObservableObject {
    @Published private(set) var board = Board()
    @Published private(set) var currentTurn: Team = .bottom // 小朋友执 bottom 先走
    @Published private(set) var winner: Team?
    @Published var selectedPiece: Hex?
    @Published private(set) var legalDestinations: [Hex] = []

    let humanTeam: Team = .bottom
    let aiTeam: Team = .top
    @Published var aiDifficulty: AIDifficulty = .medium

    func select(_ hex: Hex) {
        guard winner == nil, currentTurn == humanTeam else { return }

        if let selected = selectedPiece, legalDestinations.contains(hex) {
            let moves = MoveGenerator.availableMoves(for: selected, on: board)
            if let move = moves.first(where: { $0.to == hex }) {
                perform(move)
            }
            return
        }

        guard board.piece(at: hex) == humanTeam else {
            selectedPiece = nil
            legalDestinations = []
            return
        }
        selectedPiece = hex
        legalDestinations = MoveGenerator.availableMoves(for: hex, on: board).map(\.to)
    }

    func perform(_ move: Move) {
        board.apply(move)
        selectedPiece = nil
        legalDestinations = []

        if board.isWon(by: currentTurn) {
            winner = currentTurn
            return
        }
        currentTurn = currentTurn.opponent
        if currentTurn == aiTeam {
            requestAIMove()
        }
    }

    func requestAIMove() {
        let snapshot = board
        let team = aiTeam
        let difficulty = aiDifficulty
        Task {
            let move = await CheckersAI.bestMove(for: team, on: snapshot, difficulty: difficulty)
            await MainActor.run {
                guard let move, self.currentTurn == team, self.winner == nil else { return }
                self.perform(move)
            }
        }
    }

    func reset() {
        board = Board()
        currentTurn = .bottom
        winner = nil
        selectedPiece = nil
        legalDestinations = []
    }
}
