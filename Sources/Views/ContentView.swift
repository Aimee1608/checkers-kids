import SwiftUI

struct ContentView: View {
    @State private var session: (mode: GameMode, difficulty: AIDifficulty, jumpRule: JumpRule)?
    @AppStorage("boardSkin") private var skinRaw = BoardSkin.catppuccinMocha.rawValue
    @AppStorage("jumpRule") private var jumpRuleRaw = JumpRule.standard.rawValue

    private var skin: Binding<BoardSkin> {
        Binding(
            get: { BoardSkin(rawValue: skinRaw) ?? .catppuccinMocha },
            set: { skinRaw = $0.rawValue }
        )
    }

    private var jumpRule: Binding<JumpRule> {
        Binding(
            get: { JumpRule(rawValue: jumpRuleRaw) ?? .standard },
            set: { jumpRuleRaw = $0.rawValue }
        )
    }

    var body: some View {
        Group {
            if let session {
                GameView(
                    mode: session.mode, aiDifficulty: session.difficulty, jumpRule: session.jumpRule,
                    skin: skin.wrappedValue
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) { self.session = nil }
                }
                .transition(
                    .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                    .combined(with: .opacity)
                )
            } else {
                HomeView(skin: skin, jumpRule: jumpRule) { mode, difficulty, rule in
                    withAnimation(.easeInOut(duration: 0.3)) { self.session = (mode, difficulty, rule) }
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
