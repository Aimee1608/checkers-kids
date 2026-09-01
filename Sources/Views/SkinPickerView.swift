import SwiftUI

/// sheet 的背景交给 `.presentationBackground` 设,不要在里面自己铺一层不透明色顶到边:
/// iOS 会给 sheet 边缘画一条浅色描边,自铺的深色背景压在它下面会把亮度差拉到 3 倍
/// (量过:圆角上的像素亮度 48~84,而背景 23、弹框 29),沿弯曲的角渲染成一串明暗不均的
/// 亮点,看起来就是"毛刺"。
struct SkinPickerView: View {
    @Binding var selected: BoardSkin
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    private let background = Color(red: 0.08, green: 0.12, blue: 0.18)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(BoardSkin.allCases) { skin in
                        skinCard(skin)
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

    private func skinCard(_ skin: BoardSkin) -> some View {
        let isSelected = selected == skin
        return Button {
            Haptics.select()
            selected = skin
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: skin.boardBackground, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 90)
                    HStack(spacing: 8) {
                        gemPreview(skin.topPieceColor)
                        gemPreview(skin.bottomPieceColor)
                    }
                }
                HStack(spacing: 4) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    Text(skin.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(isSelected ? 0.16 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityIdentifier("skin_\(skin.rawValue)")
    }

    private func gemPreview(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .overlay(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.55), Color.white.opacity(0)],
                            center: UnitPoint(x: 0.32, y: 0.28),
                            startRadius: 0,
                            endRadius: 13
                        )
                    )
            )
            .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
            .frame(width: 26, height: 26)
            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
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
    SkinPickerView(selected: .constant(.catppuccinMocha))
}
