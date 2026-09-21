# AI 辅助开发说明

MoonProbe 在开发过程中使用 AI Coding 工具辅助分析、实现、测试与文档整理，但项目目标、范围、架构边界、验收标准和最终提交责任由参赛者掌握。

## AI 实际参与的工作

AI 主要参与：

- API 与数据模型草案讨论；
- MoonBit 代码生成、重构建议与编译错误修复；
- 单元测试、失败路径和回归用例补全；
- CI / GitHub Actions 配置诊断；
- Web Playground 原型与交互层实现；
- README、设计文档与验收清单整理；
- Code Review 与跨模块一致性检查。

AI 的输出不直接等同于可提交成果。每一轮进入主干的实现都经过实际构建、测试或边界验证。

## 参赛者负责的决策

以下事项始终由参赛者确认并承担责任：

1. 项目目标与比赛方向是否匹配；
2. Core / Adapter / UI 的职责边界；
3. 公共 API 与数据模型是否值得长期保留；
4. Native 与 Browser 网络能力的真实边界；
5. 测试是否验证了需求而不是只让 CI 变绿；
6. 第三方依赖、许可证与来源是否合规；
7. 是否接受 AI 给出的修复方案；
8. 最终代码、文档与提交材料的正确性。

## 实际开发闭环

MoonProbe 采用下面的工作流，而不是“生成后直接提交”：

~~~text
Goal / issue
    ↓
AI-assisted implementation or review
    ↓
Developer checks architecture and scope
    ↓
moon check --deny-warn
    ↓
moon test
    ↓
moon build
    ↓
cross-platform / adapter-specific verification
    ↓
PR → main
~~~

截至 Gate 6，Native 主路径同时在 Ubuntu 与 Windows CI 验证；Browser Bridge 还额外经过 JS target 编译与 Node ESM 实际导入调用。

## AI 输出被纠正的实例

### 1. Web 构建产物路径

Playground Bridge 初版 CI 假定 JS 构建产物位于 `target/js`。实际 MoonBit 工具链使用 `_build/js`。

该问题由 CI 冒烟测试失败暴露后修改构建脚本，并重新验证。

### 2. Browser 与 Native Transport 边界

为了避免演示层变成第二套实现，最终没有在 JavaScript 中复制 Environment / Template / Assertion / Report 规则。

浏览器只承担 `fetch`、AbortController 和界面状态；JSON wire parsing、模板展开、断言和结构化 Report 均通过 MoonBit JS Bridge 调用原有能力。

### 3. GitHub Pages 首次启用

Pages workflow 能成功编译并 stage MoonBit Bridge，但 GitHub Actions token 无权为一个尚未启用 Pages 的仓库创建 Pages site。

因此该步骤被明确记录为一次性的仓库 Settings 操作，而不是把 workflow 绿色与“线上可访问”混为一谈。

## 可解释性要求

项目文档应能回答：

- 为什么使用 Transport abstraction；
- 为什么 Request / Response / Assertion 都是结构化类型；
- 为什么 `wire/` 独立于 CLI；
- 为什么 Web 只做 Browser Adapter；
- Assertion 如何决定 pass / fail；
- Collection 的 continue / stop-on-failure 如何计数；
- 为什么 JSON Report 有 schema version；
- 哪些能力由 MoonBit 实现，哪些属于 Host/UI。

详细复盘见 [DEVELOPMENT_RETROSPECTIVE.md](DEVELOPMENT_RETROSPECTIVE.md)。

## 第三方来源

项目没有以直接移植现成 API Client 的方式开发，也没有复制来源不明代码。

直接依赖、GitHub Actions 与外部 Demo 服务的用途和许可证审查见 [THIRD_PARTY.md](THIRD_PARTY.md)。
