# App Review 回复 — Guideline 2.1 Information Needed

在 App Store Connect →「解决方案中心」(Resolution Center)里回复,把下面英文原样贴进去,
录屏作为附件上传。

---

## 回复正文(英文,直接复制 —— 3458 字符,在 4000 上限内)

```
Thank you for reviewing our app. Requested information below.

1. SCREEN RECORDING
Attached, captured on a physical iPhone 17 Pro Max running iOS 26.6, starting from app launch and covering the full user flow. The app has no account registration/login/deletion, no paid content or in-app purchases, no user-generated content, and requests no sensitive data or device permissions.

2. DEVICES AND OS TESTED
- iPhone 17 Pro Max (iPhone18,2), iOS 26.6 - physical device
- iPhone 17 Pro / iPhone 11 Pro Max, iOS 26.5 - Simulator
- iPad Pro 13-inch and 11-inch (M5), iPadOS 26.5 - Simulator
An automated UI test suite (10 tests) covering board geometry, move rules, AI response, game flow and settings runs against these targets.

3. FUNCTION AND TARGET AUDIENCE
A Chinese Checkers (Sternhalma) board game for children and parents to play together.

Problem solved: most Chinese Checkers apps today are filled with ads, in-app purchases and mandatory account registration, making them unsuitable for young children. This app is a deliberately clean alternative - no ads, no purchases, no account, no network access, no data collection.

Value: a completely offline, distraction-free board game a child can open and play immediately, either against a built-in AI or face-to-face with another person on the same device.

Audience: children (ages 5+) and their parents. Age rating 4+.

4. SETUP AND ACCESS
No credentials, sample files or setup required. There is no account system. Launch the app and all features are immediately available.

- Home screen: tap "Play vs Computer" or "Two Players" to pick a mode.
- A settings step follows: AI difficulty (Easy/Medium/Hard, vs-computer only) and jump rule (single/long jump). Tap "Start Game".
- On the board, tap one of your pieces to select it (highlighted yellow, legal destinations marked with yellow dots), then tap a marked cell to move. Chained jumps animate one hop at a time.
- Top-left house icon returns home, top-right arrow restarts; both show a confirmation dialog.
- Speaker icon opens independent toggles for background music and sound effects.
- "Skins" on the home screen switches between 5 board color themes.

5. EXTERNAL SERVICES
None. No backend server, no API calls, no data providers, no authentication, no payment processors, no AI services (the computer opponent is a local minimax algorithm with alpha-beta pruning running entirely on device), no analytics, advertising or crash reporting SDKs, and no third-party frameworks. Built with Apple's SwiftUI and AVFoundation only; functions with no network connection.

6. REGIONAL DIFFERENCES
None. The app behaves identically in all regions. No region-specific content, no region-gated features, no server-side configuration. It ships with a single Simplified Chinese localization used everywhere.

7. THIRD-PARTY MATERIAL
Not a regulated industry. The only third-party material is the background music track "Children's March Theme" by Cleyton Kauffman, released under Creative Commons Zero (CC0 1.0 Universal) public domain dedication, free for commercial use without attribution. Source: https://opengameart.org/content/childrens-march-theme

All other assets - app icon, board rendering, game pieces and all sound effects - were created by us. Sound effects are synthesized at runtime in code, not sampled from any external source.

This information has also been added to the Notes field in App Review Information for future submissions.
```

---

## 录屏怎么录

**不需要开发者模式**,用 iPhone 自带的屏幕录制就行。

### 准备
1. `设置` → `控制中心` → 找到「屏幕录制」点 ➕ 加进控制中心(如果还没加)
2. 确认「彩虹跳跳棋」还装在手机上;如果之前是用 Xcode 装的、现在打不开了,重新连电脑装一次,
   或者走 TestFlight 装

### 录制内容(1~3 分钟,把核心流程走一遍)
1. **从主屏幕点开 app 开始录**(Apple 明确要求录像从启动 app 开始)
2. 首页停留 2 秒,让审核员看清界面
3. 点「人机对战」→ 设置页选个难度、选个跳跃规则 → 点「开始对战」
4. 棋盘上**点一颗自己的棋子**(展示高亮和落点提示)→ 点一个落点走一步
5. **等电脑应手**(展示 AI 会自动走棋)
6. 再走两三步,如果能走出连跳更好(展示逐格跳动画)
7. 点右上角重开图标 → 展示二次确认弹框 → 点取消
8. 点喇叭图标 → 展示背景音乐/音效两个独立开关 → 关掉再打开 → 完成
9. 点左上角小房子 → 确认退出 → 回首页
10. 点「皮肤」→ 展示 5 套配色 → 选一套 → 完成
11. 点「双人对战」→ 进对局走一步 → 展示轮到对方(不会有电脑自动走)

### 录完
- 停止录制,视频存在「照片」里
- 传到电脑上(AirDrop 最快),在 App Store Connect 解决方案中心回复时作为附件上传

---

## 顺便:把这段也填进「App 审核信息」的备注

Apple 最后一句话说了,以后每次提交都应该把这些信息写在备注里。
上面第 3~7 项的内容可以精简后填进去,避免下次又被问一遍。
