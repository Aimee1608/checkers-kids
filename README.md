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

- 棋盘:完整六角星(121 格)。中间六边形本体不变,另外 5 个尖角(含南)由北尖角的相对坐标绕棋盘中心旋转 60°×k 得到,k=3 精确落回南尖角,靠这个自洽性验证过旋转公式没手推错。南北对战只用南北两个尖角起子,其余四角是空的装饰区。棋盘容器是圆盘(不是方板),直径按"圆心到最远格子的欧氏距离"动态算(六个尖角旋转对称,天然等距,这个距离就是外接圆半径)。
- 棋盘宽度/格子间距随可用宽度动态算(`BoardView.calcSpacing`),上限从 36pt 提到 80pt——iPad 上可用宽度大很多,之前卡在 36pt 导致棋盘小得可怜、周围一圈空白;首页卡片也加了 `frame(maxWidth: 480)`,iPad 上不会横向拉到离谱。
- 棋子是纯色圆形(`BoardSkin.topPieceColor`/`bottomPieceColor`,同配色方案里最协调的一对强调色),
  叠一层左上角径向渐变高光做出光泽感,不用贴图——之前试过开源宝石贴图,颜色是"就近凑"的近似色,
  贴图自带的大理石纹理在小尺寸下也显脏,不如纯色饱和干净。
- AI:minimax + alpha-beta,按"棋子到目标区的行进度"打分,分简单/中等/困难三档(对应搜索深度 1/2/3)。轮到 AI 时先"想"半秒再落子,不是秒下。
- 跳跃规则:`JumpRule` 两档——`standard`(不空格跳,标准规则,必须隔着棋子才能跳)、`allowEmpty`
  (空格跳,隔着空格也能跳)。两种规则下跳跃都能连续链式跳,`MoveGenerator.explore()` 里只是把
  "中间格必须有棋子"这个 guard 换成可选,`CheckersAI` 的 minimax 也按同一个 `jumpRule` 算棋,不然
  AI 会用玩家选不到的跳法。
- 首页选玩法 + 设置:点"人机对战"/"双人对战"都会先进"对局设置"步骤——人机对战额外多一个难度
  三选一(简单/中等/困难),双人对战没有难度但两种模式都能设跳跃规则,`@AppStorage` 记住上次选的
  规则跨次启动保留。难度/规则开局前定好,对局中不能再改(`GameEngine.aiDifficulty`/`jumpRule` 都是
  `let`,不是 `@Published var`)。`GameMode` 决定 `GameEngine` 是否会在切换到对方回合时自动请求 AI
  走子。
- 棋盘皮肤:首页底部"皮肤"入口,`BoardSkin` 枚举配色全部取自知名开源配色方案(色值本身不受版权
  保护),而非自己调的 RGB——摩卡糖果([Catppuccin](https://catppuccin.com))、北欧极光
  ([Nord](https://www.nordtheme.com))、德古拉([Dracula](https://draculatheme.com))、复古暗调
  ([Solarized Dark](https://ethanschoonover.com/solarized))、东京夜色
  ([Tokyo Night](https://github.com/folke/tokyonight.nvim))共5套。`@AppStorage` 记住选择,跨次
  启动保留。`BoardView`/`SkinPickerView` 都读同一份 skin 定义,不重复维护配色。
- 棋子走动有动画:连跳会按 `Move.path` 逐格"跳"给玩家看,不是瞬移到终点;单步/单跳一次平滑滑动。棋子用稳定 id(`Piece`)+ SwiftUI 视图身份来做位移动画,不是靠格子重绘。
- 对局页头部有步数计数(`GameEngine.moveCount`,双方合计,每次 `perform` +1,重开清零)。
- 玩家执下方(橙色)先手,电脑/对方执上方(绿色)。棋盘宽度随屏幕自适应,适配 iPad。
- 退出对局 / 重新开始都是文字按钮("退出"/"重开"),弹**居中 alert**(不是 confirmationDialog)、
  有独立的"取消"和确认按钮,参考 Apple HIG(破坏性操作标红、文案具体)。之前用
  `confirmationDialog` 挂小图标按钮时会被系统渲染成没有取消按钮的气泡样式,换成 `.alert` 解决。
- `.alert`/`confirmationDialog` 这类系统弹窗调制符**必须分别挂在各自的触发按钮上**,不能都挂在
  外层容器视图——挂一起会出现"点了没反应""XCUITest 找按钮时报 multiple matching elements"这类
  疑难杂症(这条踩了两次,一次 confirmationDialog 一次 alert,同一个坑)。
- 按钮有按压态反馈(缩小+变暗)、选子/落子/获胜有触觉反馈,首页↔对局有转场动画。

## 目录结构

```
Sources/
  App/         App 入口
  Models/      棋盘几何、走子规则(JumpRule)、对局状态(GameMode/GameEngine)、BoardSkin、Haptics
  AI/          minimax AI
  Views/       HomeView(选模式+难度+皮肤入口)/ GameView(对局)/ BoardView(棋盘渲染+动画)/
               SkinPickerView(选皮肤)/ DecorativeBoardPreview(首页装饰棋盘)/ Styles(PressableButtonStyle)
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
  Sources/Models/JumpRule.swift Sources/AI/CheckersAI.swift scripts/main.swift \
  -o /tmp/checkerskids_smoketest
/tmp/checkerskids_smoketest
```

(多文件传给 `swift` 解释器直接跑在这个工具链上有 bug,顶层代码所在文件必须叫
`main.swift` 并用 `swiftc` 编译成可执行文件再跑,别用 `swift a.swift b.swift` 这种写法。)
