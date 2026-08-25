import Foundation

/// 双倍坐标（doubled coordinates）表示六边形网格上的一个格子。
/// col 与 row 同奇偶,相邻格子的 col 偏移固定为 2 或 (±1,±1),
/// 这样可以用普通整数表示三角格网,不用处理半格偏移。
struct Hex: Hashable {
    let col: Int
    let row: Int

    static let neighborOffsets: [(dc: Int, dr: Int)] = [
        (-2, 0), (2, 0),
        (-1, -1), (1, -1),
        (-1, 1), (1, 1),
    ]

    func neighbors() -> [Hex] {
        (0..<6).map { stepped(direction: $0, steps: 1) }
    }

    /// 沿 neighborOffsets[direction] 方向走 steps 步(doubled coordinates 下同方向多步就是
    /// 单步偏移量的整数倍,不用逐格累加)。
    func stepped(direction: Int, steps: Int) -> Hex {
        let o = Hex.neighborOffsets[direction]
        return Hex(col: col + o.dc * steps, row: row + o.dr * steps)
    }
}
