import SwiftUI

struct ContentView: View {
    @StateObject private var engine = GameEngine()

    var body: some View {
        ZStack {
            // Background gradient
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

                    difficultyPicker
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                }
            }
        }
        .overlay {
            if let winner = engine.winner {
                winnerBanner(winner)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("跳跳棋")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(engine.currentTurn == engine.humanTeam ? "轮到你了" : "电脑思考中…")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
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
                .buttonStyle(.plain)
            }
        }
    }

    private func winnerBanner(_ winner: Team) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(winner == engine.humanTeam ? "🎉" : "🤖")
                    .font(.system(size: 60))

                Text(winner == engine.humanTeam ? "你赢了!" : "电脑赢了")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(winner == engine.humanTeam ? "太棒了，再来一局吧!" : "再试一次，你可以的!")
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
                .buttonStyle(.plain)
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
    ContentView()
}
