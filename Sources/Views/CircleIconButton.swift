import SwiftUI

/// 图标按钮统一长这样:Lucide 线性图标 + 半透明圆底。加圆底不只是好看——裸图标
/// 看不出哪里能点,小朋友容易乱戳;圆底把可点范围画出来了。
///
/// 图标是 `Assets.xcassets` 里的 SVG(template 渲染模式),不用第三方库。
struct CircleIconButton: View {
    let icon: String
    let label: String
    var diameter: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: diameter * 0.48, height: diameter * 0.48)
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: diameter, height: diameter)
                .background(Circle().fill(Color.white.opacity(0.09)))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
    }
}

/// 首页底部那种"图标在上、文字在下"的入口,同样带圆底,跟顶栏保持一套语言。
struct CircleIconLabelButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.white.opacity(0.09)))
                Text(title)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}
