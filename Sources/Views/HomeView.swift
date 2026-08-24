import SwiftUI

struct HomeView: View {
    let onSelect: (GameMode) -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.18),
                    Color(red: 0.05, green: 0.08, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 8) {
                    Text("跳跳棋")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("选个玩法开始吧")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

                VStack(spacing: 16) {
                    modeButton(
                        title: "人机对战", subtitle: "和电脑比一比", emoji: "🤖",
                        accent: Color.orange
                    ) { onSelect(.vsAI) }
                    .accessibilityIdentifier("mode_vsAI")

                    modeButton(
                        title: "双人对战", subtitle: "面对面,轮流点", emoji: "🧑‍🤝‍🧑",
                        accent: Color.green
                    ) { onSelect(.local) }
                    .accessibilityIdentifier("mode_local")
                }
                .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
        }
    }

    private func modeButton(
        title: String, subtitle: String, emoji: String, accent: Color, action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptics.select()
            action()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Text(emoji).font(.system(size: 28))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(accent.opacity(0.85))
            )
            .shadow(color: accent.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    HomeView(onSelect: { _ in })
}
