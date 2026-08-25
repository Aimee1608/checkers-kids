import Foundation

/// 跳跃永远是"隔一子对称跳":落点是以被跳的子为镜像中心、跟起点对称的那一格。
/// 标准规则要求被跳的子必须紧邻(跑道长度 0);"空格跳"放宽为被跳的子可以离得远,
/// 中间允许有空格,但不能被别的子挡着(离起点最近的那颗子才算数)。
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
        case .standard: return "被跳的子必须紧邻"
        case .allowEmpty: return "隔着空格也能跳,但不能被别的子挡着"
        }
    }
}
