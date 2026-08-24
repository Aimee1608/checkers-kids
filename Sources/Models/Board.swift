import Foundation

enum Team: Equatable {
    case top
    case bottom

    var opponent: Team { self == .top ? .bottom : .top }
}

/// 棋盘几何:完整六角星(121 格)。中心在 (col:0, row:8)。
/// 中间六边形本体(行 4...12,行宽按到中心行距离递减,5,6,7,8,9,8,7,6,5)+ 6 个尖角。
/// 北尖角(行 0...3,南北对战起始区)直接按行宽 1,2,3,4 铺;其余 5 个尖角(含南)
/// 由北尖角的相对坐标绕棋盘中心旋转 60°×k(k=1...5)得到,k=3 正好落回南尖角,
/// 用这个自洽性验证过旋转公式没错,不是手摆的。
enum BoardLayout {
    static let center = Hex(col: 0, row: 8)
    static let rowCount = 17 // AI 用行号算"离目标区的行进度",跟中心镜像对称的总行数
    private static let hexRows = 4..<13

    private static func hexRowWidth(_ row: Int) -> Int { 9 - abs(row - 8) }

    /// 北尖角相对棋盘中心的坐标(depth 1...4,depth 越大越靠近尖角顶点)。
    private static let northTrianglePattern: [(col: Int, row: Int)] = {
        var cells: [(Int, Int)] = []
        for depth in 1...4 {
            let width = 5 - depth
            let relRow = -4 - depth
            var col = -(width - 1)
            while col <= width - 1 {
                cells.append((col, relRow))
                col += 2
            }
        }
        return cells
    }()

    /// 双倍坐标 -> 立方体坐标绕中心旋转 60°×times -> 转回双倍坐标(未加回中心偏移)。
    private static func rotated(_ cell: (col: Int, row: Int), times: Int) -> (col: Int, row: Int) {
        let q = (cell.col - cell.row) / 2
        let r = cell.row
        var x = q, y = -q - r, z = r
        for _ in 0..<times {
            (x, y, z) = (-z, -x, -y)
        }
        return (col: 2 * x + z, row: z)
    }

    /// 六个尖角,按绕中心旋转的次数索引:0=北,3=南(用来验证旋转公式自洽),1/2/4/5=另外4个装饰角。
    private static func trianglePoint(times: Int) -> Set<Hex> {
        Set(northTrianglePattern.map { cell in
            let r = rotated(cell, times: times)
            return Hex(col: r.col + center.col, row: r.row + center.row)
        })
    }

    private static let northTip = trianglePoint(times: 0)
    private static let southTip = trianglePoint(times: 3)

    static func allCells() -> Set<Hex> {
        var cells = Set<Hex>()
        for row in hexRows {
            let w = hexRowWidth(row)
            var col = -(w - 1)
            while col <= w - 1 {
                cells.insert(Hex(col: col, row: row))
                col += 2
            }
        }
        for times in 0..<6 {
            cells.formUnion(trianglePoint(times: times))
        }
        return cells
    }

    static func startCells(for team: Team) -> [Hex] {
        Array(team == .top ? northTip : southTip)
    }

    /// 目标区:己方棋子全部走到对方的起始尖角即获胜。
    static func goalCells(for team: Team) -> [Hex] {
        startCells(for: team.opponent)
    }
}

/// 棋子带稳定 id(仅在开局分配一次,之后只搬家不重建),
/// 好让 UI 用 matchedGeometryEffect 认出"这是同一颗子在动",而不是瞬移。
struct Piece: Hashable {
    let id: Int
    let team: Team
}

struct Board {
    let cells: Set<Hex>
    private(set) var pieces: [Hex: Piece]

    init() {
        cells = BoardLayout.allCells()
        var pieces: [Hex: Piece] = [:]
        var nextId = 0
        for team in [Team.top, .bottom] {
            for hex in BoardLayout.startCells(for: team) {
                pieces[hex] = Piece(id: nextId, team: team)
                nextId += 1
            }
        }
        self.pieces = pieces
    }

    func piece(at hex: Hex) -> Piece? { pieces[hex] }

    func pieces(of team: Team) -> [Hex] {
        pieces.compactMap { $0.value.team == team ? $0.key : nil }
    }

    mutating func apply(_ move: Move) {
        guard let piece = pieces[move.from] else { return }
        pieces[move.from] = nil
        pieces[move.to] = piece
    }

    func applying(_ move: Move) -> Board {
        var copy = self
        copy.apply(move)
        return copy
    }

    func isWon(by team: Team) -> Bool {
        let goal = BoardLayout.goalCells(for: team)
        return goal.allSatisfy { pieces[$0]?.team == team }
    }
}
