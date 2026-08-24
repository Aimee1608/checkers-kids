import SwiftUI

struct GameView: View {
    @StateObject private var engine: GameEngine
    let onExit: () -> Void
    @State private var showExitConfirm = false
    @State private var showRestartConfirm = false

    init(mode: GameMode, onExit: @escaping () -> Void) {
        _engine = StateObject(wrappedValue: GameEngine(mode: mode))
        self.onExit = onExit
    }

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

            GeometryReader { geo in
                VStack(spacing: 12) {
                    header
                        .padding(.top, 12)

                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        BoardView(engine: engine, maxWidth: geo.size.width - 40)
                            .padding(20)
                            .frame(maxWidth: .infinity)
                    }

                    if engine.mode == .vsAI {
                        difficultyPicker
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                    } else {
                        Color.clear.frame(height: 12)
                    }
                }
            }
        }
        .overlay {
            if let winner = engine.winner {
                winnerBanner(winner)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: engine.winner)
    }

    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                Button { showExitConfirm = true } label: {
                    // 用 xmark 不用 chevron.left:后者会被系统自动打上语义化的
                    // "Back" 无障碍标签,触发系统返回手势的特殊处理,把弹窗顶掉。
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 44, height: 44) // Apple HIG 建议的最小可点区域
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityIdentifier("backToHome")
                .confirmationDialog("退出这一局?", isPresented: $showExitConfirm, titleVisibility: .visible) {
                    Button("退出", role: .destructive, action: onExit)
                    Button("取消", role: .cancel) {}
                } message: {
                    Text("当前棋局不会保存")
                }

                Spacer()

                Button { showRestartConfirm = true } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityIdentifier("restartGame")
                .confirmationDialog("重新开始这一局?", isPresented: $showRestartConfirm, titleVisibility: .visible) {
                    Button("重新开始", role: .destructive) { engine.reset() }
                    Button("取消", role: .cancel) {}
                }
            }
            .padding(.horizontal, 16)

            Text("跳跳棋")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(turnText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var turnText: String {
        if engine.mode == .vsAI {
            return engine.currentTurn == engine.humanTeam ? "轮到你了" : "电脑思考中…"
        }
        return engine.currentTurn == .bottom ? "轮到橙方" : "轮到绿方"
    }

    private var difficultyPicker: some View {
        HStack(spacing: 8) {
            ForEach(AIDifficulty.allCases, id: \.rawValue) { difficulty in
                Button {
                    engine.aiDifficulty = difficulty
                } label: {
                    Text(difficulty.label)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(engine.aiDifficulty == difficulty ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(engine.aiDifficulty == difficulty
                                      ? Color.orange.opacity(0.8)
                                      : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private func winnerBanner(_ winner: Team) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(winnerEmoji(winner))
                    .font(.system(size: 60))

                Text(winnerTitle(winner))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(winnerSubtitle(winner))
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                Button {
                    engine.reset()
                } label: {
                    Text("再来一局")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange)
                        )
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.12, green: 0.16, blue: 0.24))
            )
            .padding(.horizontal, 32)
        }
    }

    private func winnerEmoji(_ winner: Team) -> String {
        if engine.mode == .vsAI { return winner == engine.humanTeam ? "🎉" : "🤖" }
        return "🎉"
    }

    private func winnerTitle(_ winner: Team) -> String {
        if engine.mode == .vsAI { return winner == engine.humanTeam ? "你赢了!" : "电脑赢了" }
        return winner == .bottom ? "橙方赢了!" : "绿方赢了!"
    }

    private func winnerSubtitle(_ winner: Team) -> String {
        if engine.mode == .vsAI {
            return winner == engine.humanTeam ? "太棒了，再来一局吧!" : "再试一次，你可以的!"
        }
        return "换个人再来一局吧!"
    }
}

extension AIDifficulty {
    var label: String {
        switch self {
        case .easy: return "简单"
        case .medium: return "中等"
        case .hard: return "困难"
        }
    }
}

#Preview {
    GameView(mode: .vsAI, onExit: {})
}
