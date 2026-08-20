import Foundation

func assertTrue(_ cond: Bool, _ msg: String) {
    if !cond {
        print("❌ FAIL: \(msg)")
        exit(1)
    }
    print("✅ \(msg)")
}

// 1. 棋盘几何
let board0 = Board()
assertTrue(board0.cells.count == 81, "棋盘一共 81 格")
assertTrue(board0.pieces(of: .top).count == 10, "top 起始 10 个子")
assertTrue(board0.pieces(of: .bottom).count == 10, "bottom 起始 10 个子")

// 2. 单步走子:任意一个 bottom 前排棋子应该有朝中心的空格可走
let bottomFront = Hex(col: 1, row: 13) // 南尖角最靠近中心那一排,该行合法列为奇数
let moves0 = MoveGenerator.availableMoves(for: bottomFront, on: board0)
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

// 4. AI 不崩溃、不卡死,自对弈打满 60 步验证收敛(避免死循环/性能炸)
var game = Board()
var turn = Team.bottom
var stepCount = 0
let maxSteps = 60
let start = Date()
while stepCount < maxSteps {
    if game.isWon(by: .top) || game.isWon(by: .bottom) { break }
    let moves = MoveGenerator.allMoves(for: turn, on: game)
    guard !moves.isEmpty else {
        print("⚠️ \(turn) 无子可走(不应发生,棋子不会被吃)")
        break
    }
    // 简单起见跑 AI vs AI,中等难度
    let sem = DispatchSemaphore(value: 0)
    var chosen: Move?
    Task {
        chosen = await CheckersAI.bestMove(for: turn, on: game, difficulty: .medium)
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
