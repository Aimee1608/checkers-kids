# App Review 回复 — Guideline 2.1 Information Needed

在 App Store Connect →「解决方案中心」(Resolution Center)里回复,把下面英文原样贴进去,
录屏作为附件上传。

---

## 回复正文(英文,直接复制)

```
Thank you for reviewing our app. Please find the requested information below.

1. SCREEN RECORDING
A screen recording captured on a physical iPhone 17 Pro Max running iOS 26.6 is
attached. It starts from launching the app and demonstrates the complete user
flow through all core features. The app has no account registration, login, or
account deletion flows; no paid content, in-app purchases, or subscriptions; no
user-generated content; and it does not request access to any sensitive data or
device capabilities.

2. DEVICES AND OPERATING SYSTEMS TESTED
- iPhone 17 Pro Max (iPhone18,2), iOS 26.6 — physical device
- iPhone 17 Pro, iOS 26.5 — Simulator
- iPhone 11 Pro Max, iOS 26.5 — Simulator
- iPad Pro 13-inch (M5), iPadOS 26.5 — Simulator
- iPad Pro 11-inch (M5), iPadOS 26.5 — Simulator
An automated UI test suite (10 tests) covering board geometry, move rules, AI
response, game flow, and settings runs against these targets.

3. APP FUNCTION AND TARGET AUDIENCE
This is a Chinese Checkers (Sternhalma) board game built for children and
parents to play together.

Problem it solves: most Chinese Checkers apps available today are filled with
banner ads, interstitial ads, in-app purchases, and mandatory account
registration, which makes them unsuitable for young children and a poor
experience for parents. This app is a deliberately clean alternative — no ads,
no in-app purchases, no account, no network access, and no data collection of
any kind.

Value it provides: a completely offline, distraction-free board game that a
child can open and play immediately, either against a built-in AI opponent or
face-to-face with another person on the same device.

Target audience: children (approximately ages 5 and up) and their parents.
Age rating: 4+.

4. SETUP AND ACCESS INSTRUCTIONS
No login credentials, sample files, or setup steps of any kind are required.
The app has no account system. Simply launch the app and all features are
immediately accessible.

Main features and how to reach them:
- On the home screen, tap "人机对战" (Play vs Computer) or "双人对战"
  (Two Players) to choose a game mode.
- A settings step appears next. For "Play vs Computer" you can choose an AI
  difficulty (Easy / Medium / Hard). For both modes you can choose a jump rule
  (single jump / long jump). Tap "开始对战" (Start Game) to begin.
- On the board, tap one of your own pieces to select it — it is highlighted in
  yellow and all legal destination cells are marked with yellow dots. Tap a
  marked cell to move there. Chained jumps animate one hop at a time.
- The house icon at the top left returns to the home screen; the circular arrow
  icon at the top right restarts the game. Both show a confirmation dialog.
- The speaker icon opens a panel with independent toggles for background music
  and sound effects.
- The "皮肤" (Skins) button on the home screen switches between 5 board color
  themes.

5. EXTERNAL SERVICES, TOOLS, AND PLATFORMS
None. The app uses no external services whatsoever:
- No data providers, no backend server, no API calls
- No authentication services
- No payment processors
- No AI services (the computer opponent is a local minimax algorithm with
  alpha-beta pruning implemented entirely in the app; it does not contact any
  server)
- No analytics, advertising, attribution, or crash reporting SDKs
- No third-party frameworks or dependencies of any kind

The app is built with Apple's SwiftUI and AVFoundation frameworks only, and
functions with no network connection at all.

6. REGIONAL DIFFERENCES
There are none. The app functions identically in all regions. There is no
region-specific content, no region-gated features, and no server-side
configuration. The app ships with a single Simplified Chinese localization,
which is used in every region.

7. THIRD-PARTY MATERIAL
The app does not operate in a regulated industry.

The only third-party material included is the background music track,
"Children's March Theme" by Cleyton Kauffman, which is released under the
Creative Commons Zero (CC0 1.0 Universal) public domain dedication and is free
for commercial use without attribution. Source:
https://opengameart.org/content/childrens-march-theme
All other assets — the app icon, board rendering, game pieces, and all sound
effects — were created by us. The sound effects are synthesized at runtime in
code and are not sampled from any external source.

We have also added this information to the Notes field in the App Review
Information section for future submissions.

Thank you for your time.
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
