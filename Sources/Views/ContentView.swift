import SwiftUI

struct ContentView: View {
    @State private var session: (mode: GameMode, difficulty: AIDifficulty)?
    @AppStorage("boardSkin") private var skinRaw = BoardSkin.catppuccinMocha.rawValue

    private var skin: Binding<BoardSkin> {
        Binding(
            get: { BoardSkin(rawValue: skinRaw) ?? .catppuccinMocha },
            set: { skinRaw = $0.rawValue }
        )
    }

    var body: some View {
        Group {
            if let session {
                GameView(mode: session.mode, aiDifficulty: session.difficulty, skin: skin.wrappedValue) {
                    withAnimation(.easeInOut(duration: 0.3)) { self.session = nil }
                }
                .transition(
                    .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                    .combined(with: .opacity)
                )
            } else {
                HomeView(skin: skin) { mode, difficulty in
                    withAnimation(.easeInOut(duration: 0.3)) { self.session = (mode, difficulty) }
                }
                .transition(
                    .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
                    .combined(with: .opacity)
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
