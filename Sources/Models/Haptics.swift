import UIKit

enum Haptics {
    static func select() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func move() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func win() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}
