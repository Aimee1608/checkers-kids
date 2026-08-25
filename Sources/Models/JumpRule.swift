import Foundation

/// 标准规则要求被跳过的中间格必须有棋子(己方或对方都算);"空格跳"额外放宽为
/// 中间格是空的也能跳。两种规则下跳跃都能连续链式跳,区别只在能不能跳"空格"。
enum JumpRule: String, CaseIterable, Identifiable {
    case standard
    case allowEmpty

    var id: String { rawValue }

    var label: String {
        switch self {
        case .standard: return "不空格跳"
        case .allowEmpty: return "空格跳"
        }
    }

    var subtitle: String {
        switch self {
        case .standard: return "必须隔着棋子才能跳"
        case .allowEmpty: return "隔着空格也能跳,更快"
        }
    }
}
