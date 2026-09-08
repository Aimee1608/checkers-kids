import SwiftUI

/// sheet 的背景交给 `.presentationBackground` 设,不要在里面自己铺一层不透明色顶到边:
/// iOS 会给 sheet 边缘画一条浅色描边,自铺的深色背景压在它下面会把亮度差拉到 3 倍
/// (量过:圆角上的像素亮度 48~84,而背景 23、弹框 29),沿弯曲的角渲染成一串明暗不均的
/// 亮点,看起来就是"毛刺"。
struct SkinPickerView: View {
    @Binding var appearance: Appearance
    @Environment(\.dismiss) private var dismiss

    private let skinColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    private let background = Color(red: 0.08, green: 0.12, blue: 0.18)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DecorativeBoardPreview(appearance: appearance, spacing: 8)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)

                    section("经典搭配") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SkinPreset.allCases) { preset in
                                    presetCard(preset)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, -20)
                    }

                    section("棋盘") {
                        LazyVGrid(columns: skinColumns, spacing: 8) {
                            ForEach(BoardSkin.allCases) { skin in
                                skinCard(skin)
                            }
                        }
                    }

                    section("上方棋子", hint: "人机对战时电脑执上方") {
                        colorRow(for: .top)
                    }

                    section("下方棋子", hint: "人机对战时你执下方,先走") {
                        colorRow(for: .bottom)
                    }
                }
                .padding(20)
            }
            .navigationTitle("皮肤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .accessibilityIdentifier("skinPickerDone")
                }
            }
        }
        .modifier(SheetBackground(color: background))
    }

    private func section<Content: View>(
        _ title: String, hint: String? = nil, @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
            content()
            if let hint {
                Text(hint)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private func presetCard(_ preset: SkinPreset) -> some View {
        let isSelected = preset.matches(appearance)
        let a = preset.appearance
        return Button {
            Haptics.select()
            appearance = a
        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: a.skin.boardBackground, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 40)
                    .overlay(
                        HStack(spacing: 6) {
                            gem(a.top.color)
                            gem(a.bottom.color)
                        }
                    )
                Text(preset.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(isSelected ? 1 : 0.7))
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.16 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityIdentifier("preset_\(preset.rawValue)")
    }

    private func gem(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
            .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
            .frame(width: 18, height: 18)
    }

    private func skinCard(_ skin: BoardSkin) -> some View {
        let isSelected = appearance.skin == skin
        return Button {
            Haptics.select()
            appearance.skin = skin
        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: skin.boardBackground, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 34)
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.white, .green)
                                .padding(3)
                        }
                    }
                Text(skin.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.white.opacity(isSelected ? 1 : 0.7))
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.16 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityIdentifier("skin_\(skin.rawValue)")
    }

    private func colorRow(for team: Team) -> some View {
        HStack(spacing: 8) {
            ForEach(PieceColor.allCases) { color in
                colorDot(color, team: team)
            }
        }
    }

    private func colorDot(_ color: PieceColor, team: Team) -> some View {
        let isSelected = appearance.piece(for: team) == color
        let isTaken = appearance.piece(for: team.opponent) == color
        return Button {
            Haptics.select()
            if team == .top { appearance.topChoice = color } else { appearance.bottomChoice = color }
        } label: {
            ZStack {
                Circle()
                    .fill(color.color)
                    .overlay(
                        Circle().fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.55), Color.white.opacity(0)],
                                center: UnitPoint(x: 0.32, y: 0.28), startRadius: 0, endRadius: 18
                            )
                        )
                    )
                    .overlay(Circle().stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: isSelected ? 3 : 1))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 1)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .opacity(isTaken ? 0.25 : 1)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isTaken)
        .accessibilityIdentifier("piece\(team == .top ? "Top" : "Bottom")_\(color.rawValue)")
        .accessibilityLabel("\(team == .top ? "上方" : "下方")\(color.name)")
    }
}

/// `presentationBackground` 要 iOS 16.4,部署目标是 16.0,所以包一层可用性判断;
/// 老系统上退回原来的样子(边缘毛刺,但不影响功能)。
private struct SheetBackground: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.presentationBackground(color)
        } else {
            content.background(color.ignoresSafeArea())
        }
    }
}

#Preview {
    SkinPickerView(appearance: .constant(Appearance(skin: .catppuccinMocha)))
}
