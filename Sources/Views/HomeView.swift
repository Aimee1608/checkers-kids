import SwiftUI

struct HomeView: View {
    @Binding var skin: BoardSkin
    let onStart: (GameMode, AIDifficulty) -> Void

    private enum Step {
        case chooseMode
        case chooseDifficulty
    }

    @State private var step: Step = .chooseMode
    @State private var difficulty: AIDifficulty = .medium
    @State private var showingSkinPicker = false

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

            VStack(spacing: 32) {
                Spacer()

                DecorativeBoardPreview()

                VStack(spacing: 8) {
                    Text("跳跳棋")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(step == .chooseMode ? "选个玩法开始吧" : "选个难度")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Group {
                    if step == .chooseMode {
                        modeStep
                    } else {
                        difficultyStep
                    }
                }
                .frame(maxWidth: 480)
                .padding(.horizontal, 32)

                Spacer()

                utilityRow
                    .padding(.bottom, 12)
            }
        }
        .sheet(isPresented: $showingSkinPicker) {
            SkinPickerView(selected: $skin)
        }
    }

    private var modeStep: some View {
        VStack(spacing: 16) {
            modeButton(
                title: "人机对战", subtitle: "和电脑比一比", emoji: "🤖",
                accent: Color.orange
            ) {
                withAnimation(.easeInOut(duration: 0.25)) { step = .chooseDifficulty }
            }
            .accessibilityIdentifier("mode_vsAI")

            modeButton(
                title: "双人对战", subtitle: "面对面,轮流点", emoji: "🧑‍🤝‍🧑",
                accent: Color.green
            ) { onStart(.local, difficulty) }
            .accessibilityIdentifier("mode_local")
        }
    }

    private var difficultyStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                ForEach(AIDifficulty.allCases, id: \.rawValue) { level in
                    Button {
                        Haptics.select()
                        difficulty = level
                    } label: {
                        HStack {
                            Text(level.label)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            Spacer()
                            if difficulty == level {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(difficulty == level ? Color.orange.opacity(0.85) : Color.white.opacity(0.1))
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityIdentifier("difficulty_\(level.rawValue)")
                }
            }

            Button {
                onStart(.vsAI, difficulty)
            } label: {
                Text("开始对战")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.green))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityIdentifier("startVsAI")

            Button {
                withAnimation(.easeInOut(duration: 0.25)) { step = .chooseMode }
            } label: {
                Text("‹ 返回")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityIdentifier("backToModeStep")
        }
    }

    private var utilityRow: some View {
        Button {
            showingSkinPicker = true
        } label: {
            VStack(spacing: 6) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 22))
                Text("皮肤")
                    .font(.system(size: 13, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.7))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityIdentifier("openSkinPicker")
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
    HomeView(skin: .constant(.catppuccinMocha), onStart: { _, _ in })
}
