# 在线客服（iOS 原生 App）

原生 SwiftUI 客户端，对接本项目的 `backend-web`（默认 `http://<服务器>:9000`）。
**未签名构建**，用 TrollStore（巨魔）直接安装，不需要 Apple 开发者账号。

> ⚠️ 这份源码是在 Windows 上写的：本机没有 Xcode / iOS SDK，**无法在 Windows 上编译**。
> 出包请走 macOS 或 GitHub Actions（见下）。

## 功能

- 登录 / 退出，服务地址可改（记住 token，下次免登录）
- 账号列表：显示 IM 连接状态，点选即切换
- 会话列表：分页加载、下拉刷新、本地搜索（昵称 / 内容 / 商品）、未读红点
- 聊天页：
  - 历史消息分页（"加载更早"）、气泡按己方/对方分列
  - 文本发送（乐观插入，失败自动回滚并提示）
  - 图片消息展示（异步加载）
  - 快捷短语一键填入输入框
- 设置：服务地址、当前登录信息、版本、退出登录

## 目录

```
ios/
  build_ipa.sh              # macOS 一键出包
  OnlineKefu/
    project.yml             # XcodeGen 工程定义（Bundle ID / 版本 / ATS 等都在这里）
    Sources/                # Swift 源码
    Resources/Info.plist
    Resources/Assets.xcassets/   # AppIcon（1024）、LaunchLogo、启动背景色
```

- Bundle ID：`com.xianyu.onlinekefu`
- 显示名：在线客服
- 最低系统：iOS 15.0
- 已放开 ATS（`NSAllowsArbitraryLoads`），否则 `http://内网IP` 会被系统拦掉

## 出包方式一：GitHub Actions（不需要 Mac）

1. 把仓库推到 GitHub
2. 进入 **Actions → Build unsigned IPA → Run workflow**
3. 跑完在 Artifacts 里下载 `在线客服-unsigned-ipa`
4. 传到手机，用 TrollStore 打开 → Install

## 出包方式二：macOS 本地

```bash
brew install xcodegen
bash ios/build_ipa.sh
# 产物：artifacts/ipa/在线客服.ipa
```

## 安装（TrollStore）

1. 手机已装 TrollStore（巨魔）
2. 把 ipa 传到手机（AirDrop / 文件 App / 局域网）
3. 用 TrollStore 打开 ipa → Install
4. 首次打开若提示"未受信任的开发者"，TrollStore 安装时会自动做伪签名，无需额外操作

## 已知边界

- 图片**发送**未实现（需要 multipart 上传 + 转存闲鱼 CDN），目前只做展示
- 消息实时性靠手动刷新 / 进入会话拉取，未接 WebSocket 推送
- 订单、语料、智能客服配置等管理功能未做（网页端更合适）
- 登录态与网页端独立：App 里登录的是本项目账号，不是闲鱼账号
