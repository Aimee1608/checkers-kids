# 跳跳棋(CheckersKids)

纯本地对战的中国跳棋,给小朋友用,无广告、无联网、无后台服务。

## 在 Mac 上跑起来

```bash
brew install xcodegen   # 只需装一次
cd checkers-kids
xcodegen generate       # 生成 CheckersKids.xcodeproj(不进 git,每次改 project.yml 后重跑一遍)
open CheckersKids.xcodeproj
```

打开后在 Xcode 里选个模拟器(比如 iPhone 15),Cmd+R 直接跑。

真机跑/上架前需要在 Xcode 的 Signing & Capabilities 里选自己的开发者 Team(project.yml 里 `DEVELOPMENT_TEAM` 留空了,不进代码库)。

## 当前范围

- 棋盘:完整六角星(121 格)。中间六边形本体不变,另外 5 个尖角(含南)由北尖角的相对坐标绕棋盘中心旋转 60°×k 得到,k=3 精确落回南尖角,靠这个自洽性验证过旋转公式没手推错。南北对战只用南北两个尖角起子,其余四角是空的装饰区。
- 空格子颜色对比度偏低(深绿背景 + 半透明黑洞),侧边尖角的格子在小尺寸截图里肉眼不好分辨,数据/坐标是对的(有 UI 测试验证),纯视觉待打磨。
- AI:minimax + alpha-beta,按"棋子到目标区的行进度"打分,分简单/中等/困难三档(对应搜索深度 1/2/3)。轮到 AI 时先"想"半秒再落子,不是秒下。
- 首页选玩法:人机对战(vsAI)/ 双人本地对战(local,面对面轮流点,不接 AI)。`GameMode` 决定 `GameEngine` 是否会在切换到对方回合时自动请求 AI 走子。
- 棋子走动有动画:连跳会按 `Move.path` 逐格"跳"给玩家看,不是瞬移到终点;单步/单跳一次平滑滑动。棋子用稳定 id(`Piece`)+ SwiftUI 视图身份来做位移动画,不是靠格子重绘。
- 玩家执下方(橙色)先手,电脑/对方执上方(绿色)。棋盘宽度随屏幕自适应,适配 iPad。

## 目录结构

```
Sources/
  App/         App 入口
  Models/      棋盘几何、走子规则、对局状态(GameMode/GameEngine)
  AI/          minimax AI
  Views/       HomeView(选模式)/ GameView(对局)/ BoardView(棋盘渲染+动画)
scripts/
  main.swift   核心规则冒烟测试(棋盘几何/连跳/AI自对弈),不依赖 Xcode 工程
UITests/
  GameFlowUITests.swift   XCUITest:六角星格子数/坐标断言、点击落子+AI应手全链路
```

## 跑 UI 测试

```bash
xcodebuild -project CheckersKids.xcodeproj -scheme CheckersKids \
  -destination "platform=iOS Simulator,name=iPhone 15" test
```

## 跑冒烟测试

不用开 Xcode,直接编译核心逻辑跑一遍:

```bash
swiftc Sources/Models/Hex.swift Sources/Models/Board.swift Sources/Models/Move.swift \
  Sources/AI/CheckersAI.swift scripts/main.swift -o /tmp/checkerskids_smoketest
/tmp/checkerskids_smoketest
```

(多文件传给 `swift` 解释器直接跑在这个工具链上有 bug,顶层代码所在文件必须叫
`main.swift` 并用 `swiftc` 编译成可执行文件再跑,别用 `swift a.swift b.swift` 这种写法。)
