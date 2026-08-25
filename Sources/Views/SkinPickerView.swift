import SwiftUI

struct SkinPickerView: View {
    @Binding var selected: BoardSkin
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

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
            .background(Color(red: 0.08, green: 0.12, blue: 0.18).ignoresSafeArea())
            .navigationTitle("皮肤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.08, green: 0.12, blue: 0.18), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .accessibilityIdentifier("skinPickerDone")
                }
            }
        }
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

#Preview {
    SkinPickerView(selected: .constant(.catppuccinMocha))
}
