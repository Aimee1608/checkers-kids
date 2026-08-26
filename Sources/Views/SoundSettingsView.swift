import SwiftUI

struct SoundSettingsView: View {
    @ObservedObject private var sound = SoundManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                toggleRow(title: "背景音乐", subtitle: "循环播放的轻音乐", isOn: $sound.musicEnabled, id: "musicToggle")
                toggleRow(title: "音效", subtitle: "选子/移动/获胜的提示音", isOn: $sound.sfxEnabled, id: "sfxToggle")
                Spacer()
            }
            .padding(20)
            .background(Color(red: 0.08, green: 0.12, blue: 0.18).ignoresSafeArea())
            .navigationTitle("声音")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.08, green: 0.12, blue: 0.18), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .accessibilityIdentifier("soundSettingsDone")
                }
            }
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
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }
}

#Preview {
    SoundSettingsView()
}
