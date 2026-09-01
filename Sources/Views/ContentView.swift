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
                    withAnimation(.easeInOut(duration: 0.2)) { self.session = nil }
                }
                // 只做淡入淡出,不用 .move(edge:) 那种左右滑推——首页和对局页没有层级
                // 关系(不是 push/pop),横向滑动会暗示"往前进/往后退",反而别扭。
                .transition(.opacity)
            } else {
                HomeView(skin: skin, jumpRule: jumpRule) { mode, difficulty, rule in
                    withAnimation(.easeInOut(duration: 0.2)) { self.session = (mode, difficulty, rule) }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
}
