import SwiftUI

/// 按下去要有反馈(缩小+变暗),不然点了跟没点一样,界面显得死气沉沉。
/// contentShape 兜底:纯图标按钮(比如只有个 chevron)不加这个的话,
/// 可点击/可访问区域会缩到图标本身那几个像素,点不准。
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
