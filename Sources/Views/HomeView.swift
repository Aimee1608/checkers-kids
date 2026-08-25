import SwiftUI

struct HomeView: View {
    @Binding var skin: BoardSkin
    @Binding var jumpRule: JumpRule
    let onStart: (GameMode, AIDifficulty, JumpRule) -> Void

    private enum Step: Equatable {
        case chooseMode
        case chooseSettings(GameMode)
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
                    Text(stepSubtitle)
                        .font(.system(size: 17, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Group {
                    switch step {
                    case .chooseMode: modeStep
                    case .chooseSettings(let mode): settingsStep(for: mode)
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

    private var stepSubtitle: String {
        switch step {
        case .chooseMode: return "选个玩法开始吧"
        case .chooseSettings: return "选好规则再开始"
        }
    }

    private var modeStep: some View {
        VStack(spacing: 16) {
            modeButton(
                title: "人机对战", subtitle: "和电脑比一比", emoji: "🤖",
                accent: Color.orange
            ) {
                withAnimation(.easeInOut(duration: 0.25)) { step = .chooseSettings(.vsAI) }
            }
            .accessibilityIdentifier("mode_vsAI")

            modeButton(
                title: "双人对战", subtitle: "面对面,轮流点", emoji: "🧑‍🤝‍🧑",
                accent: Color.green
            ) {
                withAnimation(.easeInOut(duration: 0.25)) { step = .chooseSettings(.local) }
            }
            .accessibilityIdentifier("mode_local")
        }
    }

    @ViewBuilder
    private func settingsStep(for mode: GameMode) -> some View {
        VStack(spacing: 26) {
            if mode == .vsAI {
                settingsGroup(title: "难度") {
                    ForEach(AIDifficulty.allCases, id: \.rawValue) { level in
                        choiceChip(title: level.label, isSelected: difficulty == level) {
                            difficulty = level
                        }
                        .accessibilityIdentifier("difficulty_\(level.rawValue)")
                    }
                }
            }

            settingsGroup(title: "跳跃规则", hint: jumpRule.subtitle) {
                ForEach(JumpRule.allCases) { rule in
                    choiceChip(title: rule.label, isSelected: jumpRule == rule) {
                        jumpRule = rule
                    }
                    .accessibilityIdentifier("jumpRule_\(rule.rawValue)")
                }
            }

            Button {
                onStart(mode, difficulty, jumpRule)
            } label: {
                Text("开始对战")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(mode == .vsAI ? Color.orange : Color.green))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityIdentifier(mode == .vsAI ? "startVsAI" : "startLocal")

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

    /// 一组"圆形单选图标 + 下方文字"横排的选项(难度/跳跃规则用同一套样式,不用铺满宽度的大色块列表)。
    private func settingsGroup<Content: View>(
        title: String, hint: String? = nil, @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
            HStack(spacing: 22) {
                content()
                Spacer(minLength: 0)
            }
            if let hint {
                Text(hint)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private func choiceChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.select()
            action()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange : Color.white.opacity(0.1))
                        .overlay(Circle().stroke(isSelected ? Color.orange : Color.white.opacity(0.3), lineWidth: 1.5))
                        .frame(width: 48, height: 48)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
            }
        }
        .buttonStyle(PressableButtonStyle())
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
    HomeView(skin: .constant(.catppuccinMocha), jumpRule: .constant(.standard), onStart: { _, _, _ in })
}
