# MoonProbe 一页项目申报说明

## 项目名称

**MoonProbe — MoonBit-native API Testing Workbench**

## 项目定位

MoonProbe 是一个以 MoonBit 为主要实现语言的 API 调试与自动化测试工具。用户可以像使用常见 API 调试软件一样输入 URL、选择 HTTP 方法、配置参数并发送请求；同时，MoonProbe 将请求模型、环境变量、模板替换、响应断言、Collection 执行和测试报告实现为可复用的 MoonBit 核心能力。

项目不以“复刻完整 Postman”为目标，而聚焦于一个边界清晰的问题：

> **让开发者能够用一套 MoonBit 原生核心，完成 API 的手动调试、批量回归测试和机器可读验证。**

## 真实需求

AI 编程显著降低了后端接口的生成成本，但接口生成后仍然需要验证：

- 请求是否能够成功发送；
- 状态码是否符合预期；
- JSON 字段是否存在或等于预期值；
- 多个接口串联后是否仍然正常；
- 修改代码后旧接口是否发生回归。

传统做法往往在 GUI 工具、脚本和 CI 之间分散。MoonProbe 希望提供统一的请求与断言模型，使同一个 Collection 能被交互式 Demo、CLI、CI，甚至 AI Coding Agent 调用。

## 主要功能

首版计划实现：

1. GET / POST / PUT / PATCH / DELETE；
2. Query Params、Headers、JSON/Text Body；
3. Bearer Token 与 Basic Auth；
4. Response status / headers / body / timing；
5. `{{variable}}` 环境变量；
6. Collection；
7. 状态码、Header、JSON 字段、响应时间等断言；
8. Collection Runner；
9. Text / JSON 报告；
10. CLI 与 Web Playground。

## 技术结构

```text
                 MoonProbe Core
                       │
     ┌─────────────────┼─────────────────┐
     │                 │                 │
   Request          Assertion        Collection
   Model             Engine           Runner
     │                 │                 │
     └─────────────────┼─────────────────┘
                       │
                    Report
                       │
              ┌────────┴────────┐
              │                 │
             CLI          Web Playground
```

Web 界面只是参考应用；删除 Web 后，MoonProbe Core 仍然必须能够独立使用、测试和复用。

## MoonBit 价值

MoonBit 将主要承担：

- 强类型请求/响应模型；
- 环境变量与模板展开；
- Assertion Engine；
- Collection Runner；
- 结构化报告；
- CLI 核心逻辑；
- 测试与可复用公共 API。

项目会尽量保持核心逻辑与 UI 解耦，并以可测试、确定性的 API 为第一优先级。

## Demo

Demo 第一屏使用熟悉的 API Workbench 结构：

```text
Collections | Request Builder | Response
            | Params          | 200 OK
            | Headers         | JSON
            | Body            |
-----------------------------------------
Tests: ✓ status == 200  ✓ body.id exists
```

同时提供预置 Todo API Collection，评委可直接点击 **Run Collection**，看到多个请求依次执行以及断言通过/失败结果。

## 验收目标

- MoonBit 为主要实现语言；
- 公共仓库持续提交；
- README 与完整设计文档；
- 可运行示例；
- 自动化测试；
- CI；
- Apache-2.0 许可证；
- 可复现 Demo；
- 项目完成后发布 MoonBit package（条件允许时发布至 Mooncakes）。

## 项目边界

首版不实现 OAuth 全流程、gRPC、WebSocket、云同步、账号系统、多人协作或插件市场。目标是在有限时间内完成一个可运行、可测试、可维护的 API 测试核心与清晰 Demo。
