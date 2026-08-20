import XCTest

final class GameFlowUITests: XCTestCase {
    /// 六角星应该有 121 个格子按钮,side 三角上的远端格子(比如 col12,row4)必须存在;
    /// 只是六边形+南北角的旧版是 81 格,没有这颗子。
    func testFullHexagramCellsExist() throws {
        let app = XCUIApplication()
        app.launch()

        let allPegs = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'peg_'"))
        XCTAssertEqual(allPegs.count, 121, "棋盘应该是完整六角星 121 格")

        let hexEdge = app.buttons["peg_4_4"]   // 六边形本体自己行4的右边缘
        let triangleTip = app.buttons["peg_12_4"] // NE 尖角在同一行伸出去的远端
        XCTAssertTrue(hexEdge.exists && triangleTip.exists)
        XCTAssertGreaterThan(
            triangleTip.frame.minX, hexEdge.frame.minX + 50,
            "NE 尖角要真的往外凸,不能是跟六边形边缘重叠的退化点"
        )
    }

    func testTapMoveTriggersAIResponse() throws {
        let app = XCUIApplication()
        app.launch()

        let piece = app.buttons["peg_1_13"]
        XCTAssertTrue(piece.waitForExistence(timeout: 5), "初始棋盘里应该能找到 (1,13) 这颗子")
        piece.tap()

        let destination = app.buttons["peg_0_12"]
        XCTAssertTrue(destination.waitForExistence(timeout: 5), "选中后 (0,12) 应该是合法落点按钮")
        destination.tap()

        // peg_* 按钮每格常驻,不能用来验证落子;"轮到你了"重新出现才是端到端信号。
        let turnLabel = app.staticTexts["轮到你了"]
        XCTAssertTrue(turnLabel.waitForExistence(timeout: 15), "AI 应手完成后回合应该回到玩家")

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "after-ai-move"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
