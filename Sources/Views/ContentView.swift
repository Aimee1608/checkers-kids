import SwiftUI

struct ContentView: View {
    @StateObject private var engine = GameEngine()

    var body: some View {
        VStack(spacing: 16) {
            header

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                BoardView(engine: engine)
                    .padding(24)
            }

            difficultyPicker
        }
        .padding()
        .overlay {
            if let winner = engine.winner {
                winnerBanner(winner)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("跳跳棋")
                .font(.largeTitle.bold())
            Text(engine.currentTurn == engine.humanTeam ? "轮到你了" : "电脑思考中…")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private var difficultyPicker: some View {
        Picker("难度", selection: $engine.aiDifficulty) {
            Text("简单").tag(AIDifficulty.easy)
            Text("中等").tag(AIDifficulty.medium)
            Text("困难").tag(AIDifficulty.hard)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private func winnerBanner(_ winner: Team) -> some View {
        VStack(spacing: 16) {
            Text(winner == engine.humanTeam ? "🎉 你赢了!" : "电脑赢了,再试一次!")
                .font(.title.bold())
            Button("再来一局") { engine.reset() }
                .buttonStyle(.borderedProminent)
        }
        .padding(28)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 12)
    }
}

#Preview {
    ContentView()
}
