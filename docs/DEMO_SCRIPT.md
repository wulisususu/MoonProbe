# MoonProbe · 3 分钟评委演示脚本

目标：评委先在 10 秒内知道“它是干什么的”，再在 3 分钟内理解“为什么 MoonBit 是项目主体”。

## 0:00–0:15 · 一句话

建议口播：

> MoonProbe 是一个 MoonBit 原生的 API 调试和自动化回归测试工具。这里的网页只是演示层，Request、环境变量、断言、Collection Runner 和 Report 都由 MoonBit 核心实现。

此时画面停在 Playground 第一屏，让 Method、URL、Send、Response、Assertions、Collection 同时可见。

## 0:15–0:50 · 单请求

选择 **Get Todo**：

~~~text
GET {{base_url}}/todos/1
~~~

点击 **Send**。

指给评委看：

- HTTP status；
- duration；
- Response JSON；
- `status_is`；
- `json_equals $.id == 1`。

建议口播：

> 我不是只显示响应。这个 Response 会交回 MoonBit Assertion Engine，逐项生成结构化结果，所以 CLI、CI 和网页可以使用同一套判断。

## 0:50–1:30 · Collection

点击 **Run all**。

展示：

~~~text
Create Todo
List Todos
Get Todo
Update Todo
Delete Todo
~~~

建议口播：

> 一次接口能调通不代表修改以后不会回归。MoonProbe 可以把多个请求组成 Collection 顺序执行。Core 区分 passed、failed 和 skipped；开启 stop-on-failure 后，未执行的请求不会被错误算成失败。

## 1:30–2:05 · Native CLI

展示 README 或终端：

~~~bash
moon run cmd/moonprobe -- run examples/collections/todo-api.json \
  --env examples/env/public-demo.json \
  --format json
~~~

建议口播：

> 这不是只能在网页里运行。Native CLI 走 MoonBit 的 HttpTransport，不受浏览器 CORS 限制；JSON 报告有固定 schema，可以直接交给 CI 或脚本。

强调：

~~~text
moonprobe.collection-report.v1
~~~

## 2:05–2:35 · 架构

展示：

~~~text
                    MoonProbe Core
                         │
       ┌─────────────────┼─────────────────┐
       ▼                 ▼                 ▼
 Request/Template   Assertion Engine   Collection Runner
       │                 │                 │
       └─────────────────┼─────────────────┘
                         ▼
                 CollectionResult
                         │
                    Text / JSON
                         │
             ┌───────────┴───────────┐
             ▼                       ▼
        Native CLI             Web Playground
             │                       │
      HttpTransport             browser fetch
                                     │
                              MoonBit JS Bridge
~~~

建议口播：

> 项目刻意把 Core 和适配层拆开。删除 playground 后，MoonBit Core、Native Transport、CLI、Collection Runner 和测试仍然完整成立。

## 2:35–2:55 · 工程证据

展示 GitHub Actions。

建议口播：

> 主路径在 Ubuntu 和 Windows 都跑 strict check、test 和 build。Native HTTP 有 loopback integration test；JavaScript Bridge 不只编译，还会被 Node 真实 import 并调用导出函数验证 ABI。

## 2:55–3:00 · 收尾

建议口播：

> 所以 MoonProbe 的价值不是做一个 API 工具界面，而是把 API 调试与回归验证做成一套可复用的 MoonBit 基础能力，再用 CLI 和 Web 去证明它真的能用。

## 评委追问准备

### 为什么不用 JavaScript 全写？

因为比赛目标不是提交一个普通网页。Browser UI 只承担 host IO 和交互；Template、Assertion、Report 等可复用规则保持在 MoonBit。

### 为什么 Browser 不直接用 Native Transport？

浏览器受 CORS 和浏览器安全模型限制。强行宣称两者网络能力一致是不准确的，因此分别使用 Browser Fetch Adapter 和 Native HttpTransport。

### 为什么需要 Transport trait？

Core Runner 不应该绑死一个 HTTP 实现。FakeTransport 让错误路径和 Runner 逻辑可以确定性测试，Native HttpTransport 只是一个适配器。

### AI 在里面做了多少？

AI 辅助了实现、测试、文档和故障定位，但架构边界、Scope、验收判断和最终合并由参赛者负责。仓库中保留了 AI_USAGE 和开发复盘，并记录了被 CI 纠正的实际错误假设。

### 为什么不继续增加更多功能？

九月赛周期有限，v0.1 优先保证边界清晰、真实可运行、测试可靠和可复现。OAuth、WebSocket、完整 JSONPath、Postman compatibility 等被明确放在 Scope 外。
