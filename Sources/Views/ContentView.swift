import SwiftUI

struct ContentView: View {
    @State private var mode: GameMode?

    var body: some View {
        Group {
            if let mode {
                GameView(mode: mode) {
                    withAnimation(.easeInOut(duration: 0.3)) { self.mode = nil }
                }
                .transition(
                    .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                    .combined(with: .opacity)
                )
            } else {
                HomeView { selected in
                    withAnimation(.easeInOut(duration: 0.3)) { self.mode = selected }
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
