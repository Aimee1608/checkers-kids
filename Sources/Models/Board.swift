import Foundation

enum Team: Equatable {
    case top
    case bottom

    var opponent: Team { self == .top ? .bottom : .top }
}

/// 棋盘几何:17 行,行宽 [1,2,3,4, 5,6,7,8,9,8,7,6,5, 4,3,2,1]。
/// 中间 9 行(行 4...12)是正六边形本体,首尾各 4 行是南北两个尖角。
/// 完整六角星还有另外 4 个尖角,先不做——留到能在 Mac 上边跑边核对几何时再加。
enum BoardLayout {
    static let rowWidths: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    static let rowCount = rowWidths.count // 17
    static let topRows = 0..<4      // 上方尖角(玩家 top 的起始区)
    static let bottomRows = 13..<17 // 下方尖角(玩家 bottom 的起始区,也是 top 的目标区)

    static func allCells() -> Set<Hex> {
        var cells = Set<Hex>()
        for row in 0..<rowCount {
            let w = rowWidths[row]
            var col = -(w - 1)
            while col <= w - 1 {
                cells.insert(Hex(col: col, row: row))
                col += 2
            }
        }
        return cells
    }

    static func startCells(for team: Team) -> [Hex] {
        let rows = team == .top ? topRows : bottomRows
        var result: [Hex] = []
        for row in rows {
            let w = rowWidths[row]
            var col = -(w - 1)
            while col <= w - 1 {
                result.append(Hex(col: col, row: row))
                col += 2
            }
        }
        return result
    }

    /// 目标区:己方棋子全部走到对方的起始尖角即获胜。
    static func goalCells(for team: Team) -> [Hex] {
        startCells(for: team.opponent)
    }
}

struct Board {
    let cells: Set<Hex>
    private(set) var pieces: [Hex: Team]

    init() {
        cells = BoardLayout.allCells()
        pieces = [:]
        for team in [Team.top, .bottom] {
            for hex in BoardLayout.startCells(for: team) {
                pieces[hex] = team
            }
        }
    }

    func piece(at hex: Hex) -> Team? { pieces[hex] }

    func pieces(of team: Team) -> [Hex] {
        pieces.compactMap { $0.value == team ? $0.key : nil }
    }

    mutating func apply(_ move: Move) {
        guard let team = pieces[move.from] else { return }
        pieces[move.from] = nil
        pieces[move.to] = team
    }

    func applying(_ move: Move) -> Board {
        var copy = self
        copy.apply(move)
        return copy
    }

    func isWon(by team: Team) -> Bool {
        let goal = BoardLayout.goalCells(for: team)
        return goal.allSatisfy { pieces[$0] == team }
    }
}
