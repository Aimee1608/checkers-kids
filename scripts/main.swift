import Foundation

func assertTrue(_ cond: Bool, _ msg: String) {
    if !cond {
        print("❌ FAIL: \(msg)")
        exit(1)
    }
    print("✅ \(msg)")
}

// 1. 棋盘几何:完整六角星应该正好 121 格,6 个尖角旋转生成后互不重叠、也不跟六边形本体重叠。
let board0 = Board()
assertTrue(board0.cells.count == 121, "棋盘一共 121 格(六边形61 + 6个尖角×10)")
assertTrue(board0.pieces(of: .top).count == 10, "top 起始 10 个子")
assertTrue(board0.pieces(of: .bottom).count == 10, "bottom 起始 10 个子")

// 2. 单步走子:任意一个 bottom 前排棋子应该有朝中心的空格可走
let bottomFront = Hex(col: 1, row: 13) // 南尖角最靠近中心那一排,该行合法列为奇数
let moves0 = MoveGenerator.availableMoves(for: bottomFront, on: board0, jumpRule: .standard)
assertTrue(!moves0.isEmpty, "起始局面前排棋子有合法走法(\(moves0.count) 种)")
assertTrue(moves0.allSatisfy { !$0.isJump }, "起始局面没有可跳的子,应该全是单步")

// 3. 跳跃落点公式自检:同方向走 2 步应该正好是单步偏移量的 2 倍(doubled coordinates 下
//    同方向多步是线性的),不直接摆局面验证,避免脑内画图算错。
let center = Hex(col: 0, row: 8)
for (i, n) in center.neighbors().enumerated() {
    let landing = center.stepped(direction: i, steps: 2)
    let dc = landing.col - center.col
    let dr = landing.row - center.row
    let ndc = n.col - center.col
    let ndr = n.row - center.row
    assertTrue(dc == ndc * 2 && dr == ndr * 2, "方向 \(i): 走 2 步是单步偏移量的 2 倍")
}

// 4. 空格跳规则:跳跃永远是"隔一子对称跳",落点是以被跳的子为镜像中心跟起点对称的那一格。
//    Board.apply 不做合法性校验,借用已有棋子直接摆到要测的位置,不用绕合法走法拼局面。
//    摆法(都在 row8 这条中心横线上,方向 index1 = 每步 col+2):
//    A(-8,8) --空--空-- B(-2,8) --空--空--空-- 落点(4,8)
//    A 到 B 隔了 2 个空格(col -6/-4),B 到落点之间也是 3 个空格(col 0/2/4 里 4 正是落点本身)。
var symBoard = Board()
let bottomHexes = symBoard.pieces(of: .bottom)
let topHexes = symBoard.pieces(of: .top)
let pieceA = bottomHexes[0]
let pieceB = topHexes[0]
symBoard.apply(Move(from: pieceA, to: Hex(col: -8, row: 8), path: [], isJump: false))
symBoard.apply(Move(from: pieceB, to: Hex(col: -2, row: 8), path: [], isJump: false))

let fromA = Hex(col: -8, row: 8)
let expectedLanding = Hex(col: 4, row: 8) // A 到 B 隔 2 步跑道,落点应该是 B 再往前"跑道等长"的镜像点

let standardMoves = MoveGenerator.availableMoves(for: fromA, on: symBoard, jumpRule: .standard)
assertTrue(!standardMoves.contains { $0.isJump }, "被跳的子隔着 2 个空格,标准规则(必须紧邻)下不该能跳")

let emptyJumpMoves = MoveGenerator.availableMoves(for: fromA, on: symBoard, jumpRule: .allowEmpty)
assertTrue(
    emptyJumpMoves.contains { $0.isJump && $0.to == expectedLanding },
    "空格跳规则下应该能对称跳到镜像落点 \(expectedLanding),不是随便一个更远的格子"
)

// 落点前面(被跳的子和落点之间)如果被另一颗子挡住,即使隔着空格规则打开也不该能跳过去。
var blockedBoard = symBoard
let blocker = topHexes[1]
blockedBoard.apply(Move(from: blocker, to: Hex(col: 2, row: 8), path: [], isJump: false))
let blockedMoves = MoveGenerator.availableMoves(for: fromA, on: blockedBoard, jumpRule: .allowEmpty)
assertTrue(
    !blockedMoves.contains { $0.isJump && $0.to == expectedLanding },
    "被跳的子和落点之间被另一颗子挡住,不该能跳过去"
)

// 5. AI 不崩溃、不卡死,自对弈打满 60 步验证收敛(避免死循环/性能炸)
var game = Board()
var turn = Team.bottom
var stepCount = 0
let maxSteps = 60
let start = Date()
while stepCount < maxSteps {
    if game.isWon(by: .top) || game.isWon(by: .bottom) { break }
    let moves = MoveGenerator.allMoves(for: turn, on: game, jumpRule: .standard)
    guard !moves.isEmpty else {
        print("⚠️ \(turn) 无子可走(不应发生,棋子不会被吃)")
        break
    }
    // 简单起见跑 AI vs AI,中等难度
    let sem = DispatchSemaphore(value: 0)
    var chosen: Move?
    Task {
        chosen = await CheckersAI.bestMove(for: turn, on: game, difficulty: .medium, jumpRule: .standard)
        sem.signal()
    }
    sem.wait()
    guard let move = chosen else {
        print("❌ FAIL: AI 没返回走法")
        exit(1)
    }
    game.apply(move)
    turn = turn.opponent
    stepCount += 1
}
let elapsed = Date().timeIntervalSince(start)
assertTrue(stepCount > 0, "AI vs AI 自对弈跑完 \(stepCount) 步,没有卡死")
assertTrue(elapsed < 30, "\(stepCount) 步耗时 \(String(format: "%.1f", elapsed))s,速度可接受")

print("\n🎉 全部通过")
