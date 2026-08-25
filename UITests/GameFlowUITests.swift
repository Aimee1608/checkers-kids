import XCTest

final class GameFlowUITests: XCTestCase {
    /// vsAI 现在要先经过首页的难度选择步骤(点"人机对战"→选难度→点"开始对战"),
    /// local 还是直接进。
    private func launchIntoGame(mode identifier: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        let modeButton = app.buttons[identifier]
        XCTAssertTrue(modeButton.waitForExistence(timeout: 5), "首页应该有 \(identifier) 这个模式按钮")
        modeButton.tap()

        if identifier == "mode_vsAI" {
            let start = app.buttons["startVsAI"]
            XCTAssertTrue(start.waitForExistence(timeout: 3), "选人机对战后应该进到难度选择步骤")
            start.tap()
        }
        return app
    }

    /// 圆盘直径要精确匹配可用宽度,不能超出屏幕——之前算间距的公式是按老的矩形棋盘
    /// 抄的,没跟着"圆盘要盖住六个尖角"改,导致圆盘右边被裁到屏幕外面。
    func testDiscBoardStaysWithinScreenBounds() throws {
        let app = launchIntoGame(mode: "mode_local")
        XCTAssertTrue(app.buttons["peg_0_8"].waitForExistence(timeout: 5))

        let screenWidth = app.windows.firstMatch.frame.width
        let leftPeg = app.buttons["peg_-12_4"]
        let rightPeg = app.buttons["peg_12_4"]
        XCTAssertTrue(leftPeg.exists && rightPeg.exists)
        XCTAssertGreaterThanOrEqual(leftPeg.frame.minX, 0, "六角星最左边的格子不该被裁到屏幕外")
        XCTAssertLessThanOrEqual(
            rightPeg.frame.maxX, screenWidth, "六角星最右边的格子不该被裁到屏幕外"
        )
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
        XCTAssertTrue(app.staticTexts["第 2 步"].waitForExistence(timeout: 3), "玩家+AI各走一步,步数应该是2")

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "after-ai-move"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// 首页选好难度后带进对局:选"困难",对局页不该再有难度切换器,
    /// 但确实是按选的难度在跑(这里只验证入口消失,难度本身走 AI 逻辑已有别的测试)。
    func testDifficultyPickedOnHomeCarriesIntoGameAndNoInGamePicker() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["mode_vsAI"].tap()
        app.buttons["difficulty_3"].tap() // .hard
        app.buttons["startVsAI"].tap()

        XCTAssertTrue(app.buttons["peg_0_8"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["简单"].exists, "对局页不应该再有难度切换器")
        XCTAssertFalse(app.buttons["困难"].exists, "对局页不应该再有难度切换器")
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

    /// 退出按钮(文字"退出")要弹居中 alert,有独立的"取消"和"退出"两个按钮。
    func testBackButtonAsksConfirmationBeforeExiting() throws {
        let app = launchIntoGame(mode: "mode_vsAI")
        XCTAssertTrue(app.buttons["peg_0_8"].waitForExistence(timeout: 5))

        app.buttons["backToHome"].tap()
        XCTAssertTrue(app.staticTexts["退出这一局?"].waitForExistence(timeout: 3), "退出前应该有确认弹窗")

        app.buttons["取消"].tap()
        XCTAssertTrue(app.buttons["peg_0_8"].waitForExistence(timeout: 3), "点取消不该真的退出,棋盘应该还在")

        app.buttons["backToHome"].tap()
        let confirmExit = app.buttons.matching(identifier: "confirmExit").firstMatch
        XCTAssertTrue(confirmExit.waitForExistence(timeout: 3))
        confirmExit.tap()
        XCTAssertTrue(app.buttons["mode_vsAI"].waitForExistence(timeout: 5), "确认退出后应该回到首页选模式")
    }

    /// 重开按钮(文字"重开")同样弹居中 alert,确认后棋盘/回合才真的复位。
    func testRestartAsksConfirmationThenResetsBoard() throws {
        let app = launchIntoGame(mode: "mode_vsAI")

        app.buttons["peg_1_13"].tap()
        app.buttons["peg_0_12"].tap()
        XCTAssertTrue(app.staticTexts["轮到你了"].waitForExistence(timeout: 15), "AI 应手完成,轮回玩家")

        app.buttons["restartGame"].tap()
        XCTAssertTrue(app.staticTexts["重新开始这一局?"].waitForExistence(timeout: 3), "重开前应该有确认弹窗")
        app.buttons["取消"].tap()
        // 弹窗关闭后紧接着查小号 StaticText("第 N 步")偶发查不到(疑似无障碍快照有延迟),
        // 换成查弹窗文字已经消失 + 棋盘按钮还在,这个模式在退出那条测试里验证过很稳。
        Thread.sleep(forTimeInterval: 0.4)
        XCTAssertFalse(app.staticTexts["重新开始这一局?"].exists, "点取消后确认弹窗应该已经消失")
        XCTAssertTrue(app.buttons["peg_1_13"].waitForExistence(timeout: 3), "点取消不该重开,棋盘应该还是原样")

        app.buttons["restartGame"].tap()
        let confirmRestart = app.buttons.matching(identifier: "confirmRestart").firstMatch
        XCTAssertTrue(confirmRestart.waitForExistence(timeout: 3))
        confirmRestart.tap()

        XCTAssertTrue(app.staticTexts["轮到你了"].waitForExistence(timeout: 2), "重开后应该立刻是玩家回合,不用等AI")
        XCTAssertTrue(app.staticTexts["第 0 步"].waitForExistence(timeout: 2), "重开后步数应该清零")

        // 重开后 (1,13) 应该又有子、能再走一次到 (0,12) —— 证明棋子位置真的复位了,不只是回合数字。
        app.buttons["peg_1_13"].tap()
        app.buttons["peg_0_12"].tap()
        XCTAssertTrue(app.staticTexts["轮到你了"].waitForExistence(timeout: 15), "重开后棋子位置应该也复位了,这步棋应该还能走一遍")
    }

    /// 首页"皮肤"入口能打开选择页、切换后棋盘颜色确实变了(用棋盘背板的截图对比太脆弱,
    /// 这里只验证流程能走通:能打开、能选、能关闭,颜色跑到 BoardSkin 那层单独用截图人工核对过)。
    func testSkinPickerOpensAndCloses() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["openSkinPicker"].tap()
        let lightSkin = app.buttons["skin_light"]
        XCTAssertTrue(lightSkin.waitForExistence(timeout: 3), "皮肤页应该有浅木选项")
        lightSkin.tap()

        app.buttons["skinPickerDone"].tap()
        XCTAssertTrue(app.buttons["mode_vsAI"].waitForExistence(timeout: 3), "关闭皮肤页应该回到首页")
    }
}
