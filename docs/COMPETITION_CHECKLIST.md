# 2026 MoonBit 黑客松 · 九月赛验收清单

> 本文用于项目内部跟踪。最终规则以赛事官方通知为准。

## 官方关键要求映射

### 1. MoonBit 为主

- [ ] MoonBit 为项目主要实现语言
- [x] Core / Runner / Assertions 由 MoonBit 实现
- [ ] UI 不承载核心逻辑

### 2. 仓库公开且开发过程可追踪

- [x] GitHub 公开仓库
- [x] 持续 commits
- [x] 使用 Issues 跟踪主要工作
- [x] 重要重构尽量保留 PR 或明确 commit
- [x] CHANGELOG 持续更新

### 3. 能够运行

- [ ] README 有安装步骤
- [ ] README 有最小运行示例
- [ ] 提供 examples
- [ ] 提供 Demo
- [x] 新环境可复现

### 4. 必要测试

- [x] Core unit tests
- [x] Assertion tests
- [x] Collection tests
- [x] FakeTransport tests
- [x] CI 通过

### 5. 开源合规

- [x] Apache-2.0
- [ ] 所有依赖许可证检查
- [ ] 如有参考/移植，记录来源与范围
- [ ] 不提交密钥、账号或私有数据

### 6. AI 可解释

- [x] AI_USAGE.md
- [x] 关键架构有文档
- [ ] 参赛者可以解释实现
- [ ] AI 生成代码必须测试后提交

## 报名材料

官方九月赛要求报名时提交：

- [ ] 参赛信息
- [x] 公开仓库
- [x] 一页项目说明：`docs/PROJECT_PROPOSAL.md`
- [ ] 加入赛事交流群

## 验收材料

截至 2026-09-30 前至少准备：

- [ ] 完整代码
- [ ] README
- [ ] Tests
- [ ] 可复现 Demo 说明
- [ ] 最新项目说明
- [ ] 运行截图 / 演示链接（如适用）
- [ ] Release / tag（建议）
- [ ] Mooncakes 发布（若项目状态允许）

## 评审自检

### 10 秒理解测试

陌生评委打开 Demo：

- [ ] 能看出是 API 工具
- [ ] 能找到 URL
- [ ] 能找到 Send
- [ ] 能看到 Response
- [ ] 能看到 Test Result

### 删除 UI 测试

假设删除 `playground/`：

- [ ] Core 仍可 import
- [ ] CLI 仍可运行
- [x] Collection 仍可执行
- [ ] 测试仍可运行

### 删除 AI 叙事测试

假设 README 完全不提 AI：

- [ ] 项目仍有独立价值
- [ ] API 调试场景仍成立
- [ ] Collection Runner 仍成立

## 当前状态

2026-09-21：Gate 1–4 完成；Core、Transport、单请求/Collection Runner、Assertions 与 Text/JSON Report 均已有自动测试。5 请求 Todo Collection、stop-on-failure 与结构化 report 已通过 CI；下一步进入 CLI。
