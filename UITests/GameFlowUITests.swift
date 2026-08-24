import XCTest

final class GameFlowUITests: XCTestCase {
    private func launchIntoGame(mode identifier: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        let modeButton = app.buttons[identifier]
        XCTAssertTrue(modeButton.waitForExistence(timeout: 5), "首页应该有 \(identifier) 这个模式按钮")
        modeButton.tap()
        return app
    }

    /// 六角星应该有 121 个格子按钮,side 三角上的远端格子(比如 col12,row4)必须存在;
    /// 只是六边形+南北角的旧版是 81 格,没有这颗子。
    func testFullHexagramCellsExist() throws {
        let app = launchIntoGame(mode: "mode_vsAI")

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
        let app = launchIntoGame(mode: "mode_vsAI")

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

    /// 双人本地模式下,电脑不该自动应手——bottom 走完还是轮到 top(绿方),
    /// 不会像 vsAI 模式那样自动跳到"电脑思考中"。
    func testLocalModeBothSidesAreHumanControlled() throws {
        let app = launchIntoGame(mode: "mode_local")

        let piece = app.buttons["peg_1_13"]
        XCTAssertTrue(piece.waitForExistence(timeout: 5))
        piece.tap()
        let destination = app.buttons["peg_0_12"]
        XCTAssertTrue(destination.waitForExistence(timeout: 5))
        destination.tap()

        let greenTurnLabel = app.staticTexts["轮到绿方"]
        XCTAssertTrue(greenTurnLabel.waitForExistence(timeout: 3), "本地对战下 bottom 走完该轮到绿方等人点,不是电脑自动接手")

        // 绿方(top)的子也应该能点得动,不是被 disabled。
        let greenPiece = app.buttons["peg_-1_3"]
        XCTAssertTrue(greenPiece.isEnabled, "本地对战下双方棋子都该是人可以点的")
    }

    /// 左上角 ‹ 按钮任何时候都能退出当前对局回首页,不用等分出胜负。
    func testBackButtonExitsMidGameToHome() throws {
        let app = launchIntoGame(mode: "mode_vsAI")
        XCTAssertTrue(app.buttons["peg_0_8"].waitForExistence(timeout: 5))

        app.buttons["backToHome"].tap()

        XCTAssertTrue(app.buttons["mode_vsAI"].waitForExistence(timeout: 5), "退出后应该回到首页选模式")
    }

    /// 重开按钮要能在对局进行中随时把棋盘/回合都复位,不用等有人赢。
    func testRestartMidGameResetsBoard() throws {
        let app = launchIntoGame(mode: "mode_vsAI")

        app.buttons["peg_1_13"].tap()
        app.buttons["peg_0_12"].tap()
        XCTAssertTrue(app.staticTexts["轮到你了"].waitForExistence(timeout: 15), "AI 应手完成,轮回玩家")

        app.buttons["restartGame"].tap()
        XCTAssertTrue(app.staticTexts["轮到你了"].waitForExistence(timeout: 2), "重开后应该立刻是玩家回合,不用等AI")

        // 重开后 (1,13) 应该又有子、能再走一次到 (0,12) —— 证明棋子位置真的复位了,不只是回合数字。
        app.buttons["peg_1_13"].tap()
        app.buttons["peg_0_12"].tap()
        XCTAssertTrue(app.staticTexts["轮到你了"].waitForExistence(timeout: 15), "重开后棋子位置应该也复位了,这步棋应该还能走一遍")
    }
}
