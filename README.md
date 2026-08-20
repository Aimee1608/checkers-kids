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

- 棋盘:中间六边形 + 南北两个尖角(81 格),对应经典"南北对战"玩法。完整六角星(另外 4 个角)还没做——那部分几何推导复杂,想等能实时跑模拟器核对效果时再加,架构上（`Board`/`BoardLayout`）已经是按"合法格子集合"设计的，扩展不用重写引擎。
- AI:minimax + alpha-beta,按"棋子到目标区的行进度"打分,分简单/中等/困难三档(对应搜索深度 1/2/3)。
- 玩家执下方(橙色)先手,电脑执上方(绿色)。

## 目录结构

```
Sources/
  App/         App 入口
  Models/      棋盘几何、走子规则、对局状态
  AI/          minimax AI
  Views/       SwiftUI 界面
scripts/
  main.swift   核心规则冒烟测试(棋盘几何/连跳/AI自对弈),不依赖 Xcode 工程
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
