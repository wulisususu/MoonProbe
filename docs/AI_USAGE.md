# AI 辅助开发说明

MoonProbe 允许并计划使用 AI Coding 工具辅助开发。

## AI 可参与

- API 草案讨论
- MoonBit 代码生成与重构
- 测试用例补全
- 文档初稿
- UI 原型
- Bug 定位
- Code Review 辅助

## 参赛者负责

以下内容不能交给 AI 自动决定后直接接受：

1. 项目目标与边界；
2. 核心架构；
3. 公共 API 稳定性；
4. 网络与安全行为；
5. 测试是否真正验证需求；
6. 第三方代码与许可证合规；
7. 最终提交代码的正确性。

## AI 代码进入仓库前

应至少经过：

```text
Generated / Suggested
        ↓
Developer Review
        ↓
moon fmt
        ↓
moon check
        ↓
moon test
        ↓
Commit
```

## 可解释性要求

对于 Core 中的关键设计，仓库应能回答：

- 为什么使用该数据模型？
- 为什么存在 Transport abstraction？
- 为什么 Web 与 Native 分开？
- Assertion 如何决定 pass/fail？
- Collection 失败策略是什么？
- 什么由 MoonBit 实现，什么只是 UI？

## 第三方来源

若后续参考或移植现有开源实现：

- 在对应文件/文档标明来源；
- 记录原项目链接；
- 检查许可证兼容性；
- 明确本项目新增/改写范围；
- 不复制来源不明代码。

当前项目定位为原创实现，不以直接移植某个现成 API Client 为开发路线。
