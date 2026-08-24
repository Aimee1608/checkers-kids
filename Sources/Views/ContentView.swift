import SwiftUI

struct ContentView: View {
    @State private var mode: GameMode?

    var body: some View {
        if let mode {
            GameView(mode: mode) { self.mode = nil }
        } else {
            HomeView { self.mode = $0 }
        }
    }
}

#Preview {
    ContentView()
}
