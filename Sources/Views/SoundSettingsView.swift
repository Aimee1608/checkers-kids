import SwiftUI

/// 居中弹框,不是 `.sheet`——`.sheet` 在 iPhone 上会渲染成底部上拉的半截卡片,
/// 跟 app 里其它确认弹窗(退出/重开的 alert、获胜面板)的居中风格不一致。
struct SoundSettingsView: View {
    @ObservedObject private var sound = SoundManager.shared
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 14) {
                Text("声音")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 2)

                toggleRow(
                    title: "背景音乐", subtitle: "循环播放的轻音乐",
                    isOn: $sound.musicEnabled, id: "musicToggle"
                )
                toggleRow(
                    title: "音效", subtitle: "选子 / 移动 / 获胜的提示音",
                    isOn: $sound.sfxEnabled, id: "sfxToggle"
                )

                Button(action: onClose) {
                    Text("完成")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.orange))
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityIdentifier("soundSettingsDone")
                .padding(.top, 4)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.12, green: 0.16, blue: 0.24))
            )
            .frame(maxWidth: 420)
            .padding(.horizontal, 32)
        }
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>, id: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.orange)
                .accessibilityIdentifier(id)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }
}

#Preview {
    ZStack {
        Color(red: 0.08, green: 0.12, blue: 0.18).ignoresSafeArea()
        SoundSettingsView(onClose: {})
    }
}
