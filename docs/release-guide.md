# 迭代与发版指南

首次上架那一堆配置**都是一次性的,不用再走**。下面只写每次迭代真正要做的事。

---

## 一、已经配好、永远不用再碰的

| 项目 | 值 / 位置 |
|---|---|
| Bundle ID | `com.aimee.checkerskids` |
| App Store 名称 | 彩虹跳跳棋 |
| 隐私政策 URL | https://aimee1608.github.io/checkers-kids/privacy-policy |
| 分类 | 游戏 → 桌面游戏 / 益智解谜游戏 |
| 年龄分级 | 4+(全选"无") |
| App 隐私 | 不收集数据 |
| 审核备注 | 已填在 ASC「App 审核信息 → 备注」,会沿用 |
| 上架文案 | [`app-store-listing.md`](app-store-listing.md) |

真机也已注册在开发者账号里(iPhone 17 Pro Max),换新设备才需要重新注册。

---

## 二、日常开发闭环

改完代码后:重新生成工程 → 跑测试 → 装模拟器验证。

```bash
xcodegen generate      # 改过 project.yml 就必须重跑
xcodebuild -project CheckersKids.xcodeproj -scheme CheckersKids \
  -destination 'id=<模拟器UDID>' test
```

跑 `xcrun simctl list devices` 拿模拟器 UDID。

核心逻辑(棋盘几何/走子规则/AI)可以不开 Xcode 工程直接编译跑:

```bash
swiftc Sources/Models/Hex.swift Sources/Models/Board.swift Sources/Models/Move.swift \
  Sources/Models/JumpRule.swift Sources/AI/CheckersAI.swift scripts/main.swift \
  -o /tmp/smoketest && /tmp/smoketest
```

> 含顶层代码的文件必须叫 `main.swift` 并用 `swiftc` 编译成可执行文件,
> 别用 `swift a.swift b.swift` 解释器模式(多文件下行为不可靠)。

---

## 三、发版流程(每次迭代就这 3 步)

### 1. 升版本号

改 `project.yml`:

```yaml
MARKETING_VERSION: "1.0.2"      # 用户看到的版本号
CURRENT_PROJECT_VERSION: "4"    # build 号,只增不减,不能跟已上传过的重复
```

同步到 Mac 后 `xcodegen generate`。

### 2. 打包 + 上传

```bash
xcodebuild -project CheckersKids.xcodeproj -scheme CheckersKids \
  -destination 'generic/platform=iOS' -allowProvisioningUpdates \
  -archivePath /tmp/CheckersKids.xcarchive archive
```

看到 `** ARCHIVE SUCCEEDED **` 即成功。然后搬到 Organizer 能看到的位置:

```bash
mkdir -p ~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d) && \
cp -R /tmp/CheckersKids.xcarchive ~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/
```

Xcode → `Window` → `Organizer` → 选中这个 archive → **Distribute App** → App Store Connect → Upload。

> Organizer 只扫 `~/Library/Developer/Xcode/Archives`,放 `/tmp` 里它看不见。
>
> 想完全终端化(免开 Xcode)需要配 App Store Connect API 密钥,见文末。

### 3. App Store Connect

1. 我的 App → 彩虹跳跳棋 → 左侧 **「+ 版本或平台」** → 填新版本号
2. **截图**:UI 有明显变化时必须换,否则违反 Guideline 2.3.3。重新生成见下节
3. 填「**本次更新内容**」
4. 选构建版本(上传后要等 10~30 分钟处理完才出现)
5. **添加以供审核** → **提交以供审核**

---

## 四、重新生成上架截图

需要三种尺寸,写个临时 XCUITest 跑一遍就行(截完删掉,不要留在仓库里):

| 显示屏 | 模拟器 | 像素 |
|---|---|---|
| iPhone 6.9" | iPhone 17 Pro Max | 1320 × 2868 |
| iPhone 6.5" | iPhone 11 Pro Max(需 `simctl create` 临时建) | 1242 × 2688 |
| iPad 13" | iPad Pro 13-inch (M5) | 2064 × 2752 |

流程:临时测试里 `XCTAttachment(screenshot:)` 逐屏截 → `xcodebuild ... -resultBundlePath X.xcresult test`
→ `xcrun xcresulttool export attachments` 导出 → 按尺寸分目录放到桌面 → 网页上传。

---

## 五、审核踩过的坑

| Guideline | 现象 | 原因 / 修法 |
|---|---|---|
| — | 上传报 `No orientations were specified` | `Info.plist` 必须声明 `UISupportedInterfaceOrientations`,iPad 多任务强制。注意 `GENERATE_INFOPLIST_FILE` **不认** `KEY~ipad` 这种带 idiom 后缀的写法 |
| 2.1 | 要求补充信息 | 审核备注写太简略。已填好完整说明,会沿用;真要再问,回复模板见 [`review-reply-2.1.md`](review-reply-2.1.md) |
| 2.3.7 | 副标题被拒 | 名称/副标题/关键词/宣传文本里**不能出现价格表述**,"无广告""无内购""免费"都算。**描述里可以写** |

另外:重新提交前若「重新提交至 App 审核」按钮是灰的,说明版本没有任何改动,
随便编辑一处(比如补审核备注)存一下就会亮。

---

## 六、想让上传也走终端

需要一次性配 App Store Connect API 密钥(因为 Apple ID 开了双重认证,脚本过不了验证码):

1. ASC → **用户和访问** → **集成** → **App Store Connect API** → 生成密钥,角色 **App Manager**
2. 记下 **密钥 ID** 和 **Issuer ID**,下载 `.p8` 文件(**只能下载一次**)
3. `.p8` 放到 `~/.appstoreconnect/private_keys/`
4. 之后 `xcodebuild -exportArchive` 配合 `-authenticationKeyPath/-authenticationKeyID/-authenticationKeyIssuerID`
   即可直接上传,不用开 Xcode

配好后第 2 步能压成一条命令。第 3 步(建版本/传截图/写更新说明)理论上也能走 API,
但要写不少脚本,迭代不频繁的话网页点更划算。
