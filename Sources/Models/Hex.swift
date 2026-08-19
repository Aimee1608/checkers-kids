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
        Hex.neighborOffsets.map { Hex(col: col + $0.dc, row: row + $0.dr) }
    }

    /// 沿 neighborOffsets[direction] 方向跳过一个棋子后的落点。
    func jumpLanding(direction: Int) -> Hex {
        let o = Hex.neighborOffsets[direction]
        return Hex(col: col + o.dc * 2, row: row + o.dr * 2)
    }
}
