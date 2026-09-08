import SwiftUI

struct ContentView: View {
    @State private var session: (mode: GameMode, difficulty: AIDifficulty, jumpRule: JumpRule)?
    @AppStorage("boardSkin") private var skinRaw = BoardSkin.catppuccinMocha.rawValue
    @AppStorage("pieceColorTop") private var topRaw = ""
    @AppStorage("pieceColorBottom") private var bottomRaw = ""
    @AppStorage("jumpRule") private var jumpRuleRaw = JumpRule.standard.rawValue

    private var appearance: Binding<Appearance> {
        Binding(
            get: {
                Appearance(
                    skin: BoardSkin(rawValue: skinRaw) ?? .catppuccinMocha,
                    topChoice: PieceColor(rawValue: topRaw),
                    bottomChoice: PieceColor(rawValue: bottomRaw)
                )
            },
            set: {
                skinRaw = $0.skin.rawValue
                topRaw = $0.topChoice?.rawValue ?? ""
                bottomRaw = $0.bottomChoice?.rawValue ?? ""
            }
        )
    }

    private var jumpRule: Binding<JumpRule> {
        Binding(
            get: { JumpRule(rawValue: jumpRuleRaw) ?? .standard },
            set: { jumpRuleRaw = $0.rawValue }
        )
    }

    // 首页↔对局不加任何转场:两个页面没有层级关系,滑推会暗示"前进/后退",
    // 淡入淡出也仍有等待感——直接瞬切最跟手。
    var body: some View {
        if let session {
            GameView(
                mode: session.mode, aiDifficulty: session.difficulty, jumpRule: session.jumpRule,
                appearance: appearance.wrappedValue
            ) {
                // 得写 self.:`if let session` 把 @State 遮蔽成了同名的 let 常量。
                self.session = nil
            }
        } else {
            HomeView(appearance: appearance, jumpRule: jumpRule) { mode, difficulty, rule in
                self.session = (mode, difficulty, rule)
            }
        }
    }
}

#Preview {
    ContentView()
}
