# 2026 MoonBit 黑客松 · 九月赛验收清单

> 本文按九月赛官方页面当前要求整理。九月赛报名与验收截止时间均为 **2026-09-30**。

## 官方验收要求映射

### 1. MoonBit 为主

- [x] Core / Runner / Assertions 由 MoonBit 实现
- [x] Native HTTP Transport 由 MoonBit 实现
- [x] CLI / wire parser 由 MoonBit 实现
- [x] Browser Bridge 由 MoonBit JS target 实现
- [x] UI 不复制 Template / Assertion / Report 核心逻辑

当前 Git tree 粗略按主要源码文件字节数统计：

~~~text
.mbt                83,695 bytes
.js + .html + .css  20,364 bytes
~~~

MoonBit 是主要源码实现语言；该统计仅作证据，不作为质量评分。

### 2. 仓库公开、过程可追踪

- [x] GitHub 公开仓库
- [x] 持续 commits
- [x] 使用 Issues 跟踪主要 Gate
- [x] 关键功能通过 PR 合并
- [x] CHANGELOG 持续更新
- [x] 开发复盘：`docs/DEVELOPMENT_RETROSPECTIVE.md`

### 3. 能够运行

- [x] README 有安装步骤
- [x] README 有最小运行示例
- [x] 提供 Request / Collection / Environment examples
- [x] Linux Native check/test/build
- [x] Windows Native check/test/build
- [x] JS target Bridge check/build
- [x] Node 实际导入并调用生成的 ESM Bridge
- [x] Browser module syntax check

### 4. 工作有效

- [x] 本期从空仓库持续开发到 Gate 6
- [x] Core / Native / CLI / Browser 均为本期实质新增
- [x] 不属于重复提交、拆分项目或简单修改

### 5. 开源合规

- [x] MoonProbe 使用 Apache-2.0
- [x] 直接 MoonBit 依赖许可证已检查
- [x] GitHub Actions 许可证已检查
- [x] 第三方用途与来源记录在 `docs/THIRD_PARTY.md`
- [x] 无直接移植现成 API Client
- [x] 示例不包含真实账号、密钥或私有数据
- [x] 部署 workflow 在公开仓库

### 6. AI 可解释

- [x] `docs/AI_USAGE.md`
- [x] `docs/DEVELOPMENT_RETROSPECTIVE.md`
- [x] 关键架构决策有文档
- [x] AI 建议进入 main 前经过 check/test/build
- [x] 记录 AI / 自动化假设被 CI 纠正的实例
- [ ] 参赛者完成一次口头架构讲解演练

## 功能完成度

- [x] Request / Response Models
- [x] Environment / Template
- [x] Assertions
- [x] Replaceable Transport
- [x] Native HttpTransport
- [x] Single Request Runner
- [x] Collection Runner
- [x] continue / stop-on-failure
- [x] Text Report
- [x] versioned JSON Report
- [x] Native CLI
- [x] Web Playground
- [x] Built-in 5-request Todo scenario

## 测试与工程质量

- [x] Core unit tests
- [x] Template tests
- [x] Assertion tests
- [x] Collection tests
- [x] FakeTransport tests
- [x] loopback HTTP integration tests
- [x] timeout / transport failure coverage
- [x] JSON report schema tests
- [x] CLI wire parser tests
- [x] JS Bridge ABI smoke test
- [x] `moon check --deny-warn`

## 10 秒 Demo 自检

- [x] 能看出是 API 调试 / 测试工具
- [x] 能找到 Method / URL
- [x] 能找到 Send
- [x] 能看到 Response
- [x] 能看到 Assertions
- [x] 能看到 Collection
- [x] 能找到 Run all

## 删除适配层自检

假设删除 `playground/`：

- [x] Core 仍可 import
- [x] Native Transport 仍可使用
- [x] CLI 仍可运行
- [x] Collection 仍可执行
- [x] Tests 仍可运行

假设 README 完全不提 AI：

- [x] API 调试场景仍成立
- [x] Collection Runner 仍成立
- [x] Reporter / CLI 仍有独立价值

## 最终提交材料

- [x] 完整代码
- [x] README
- [x] Tests
- [x] Demo 源码与构建 workflow
- [x] 最新项目说明：`docs/PROJECT_PROPOSAL.md`
- [x] 开发复盘
- [x] AI 使用说明
- [x] 第三方 / 许可证说明
- [ ] GitHub Pages 在线地址
- [ ] 运行截图 / 演示截图
- [ ] Release / tag
- [ ] Mooncakes 发布（条件允许时）
- [ ] 加入赛事交流群
- [ ] 根据官方报名入口提交参赛信息

## GitHub Pages 当前状态

Playground 与 MoonBit JS Bridge 已成功构建和 stage。

首次 Pages site 创建时，GitHub Actions token 返回：

~~~text
Resource not accessible by integration
~~~

需要仓库管理员一次性进入：

~~~text
Settings → Pages → Build and deployment → Source → GitHub Actions
~~~

启用后重新运行 `pages` workflow 即可继续部署。该问题不是代码构建失败。
