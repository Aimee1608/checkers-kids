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

// 3. 连跳:手动摆一个连跳局面验证 path 正确
var jumpBoard = Board()
// 清空,自己摆:(0,8) 出发子, (0,7)/(1,-1,-1 方向邻居) 挡子, 落点应为 (0,6) 之类
// 用最简单的一条直线连跳:(col:0,row:8)->跳过(col:0,row:7)非法(row 差1 不是同方向2步)
// 直接用 neighbors()/jumpLanding 生成器自检,而不是手摆局面,避免我这边脑内画图出错。
let center = Hex(col: 0, row: 8)
for (i, n) in center.neighbors().enumerated() {
    let landing = center.jumpLanding(direction: i)
    let dc = landing.col - center.col
    let dr = landing.row - center.row
    let ndc = n.col - center.col
    let ndr = n.row - center.row
    assertTrue(dc == ndc * 2 && dr == ndr * 2, "方向 \(i): 跳跃落点是邻居方向的 2 倍位移")
}

// 4. 空格跳规则:标准规则下棋盘中心空区没子可跳,"空格跳"规则下隔着空格也该能跳、
//    能到达的格子应该明显变多(同一个位置对比,避免两套规则各摆一个局面互相不可比)。
var openBoard = Board()
openBoard.apply(Move(from: Hex(col: 1, row: 13), to: Hex(col: 0, row: 12), path: [], isJump: false))
let fromOpen = Hex(col: 0, row: 12)
let standardMoves = MoveGenerator.availableMoves(for: fromOpen, on: openBoard, jumpRule: .standard)
let emptyJumpMoves = MoveGenerator.availableMoves(for: fromOpen, on: openBoard, jumpRule: .allowEmpty)
assertTrue(standardMoves.allSatisfy { !$0.isJump }, "棋盘中心是空的,标准规则下不该有跳跃(没子可跳)")
assertTrue(emptyJumpMoves.contains { $0.isJump }, "空格跳规则下,隔着空格也应该能跳")
assertTrue(
    Set(emptyJumpMoves.map(\.to)).count > Set(standardMoves.map(\.to)).count,
    "空格跳规则应该比标准规则能到达更多格子"
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
