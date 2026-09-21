# MoonProbe 架构设计

## 总体架构

```text
                         ┌────────────────────┐
                         │   Web Playground   │
                         └─────────┬──────────┘
                                   │
                         ┌─────────▼──────────┐
                         │   Public Core API   │
                         └─────────┬──────────┘
                                   │
     ┌───────────────┬─────────────┼─────────────┬───────────────┐
     ▼               ▼             ▼             ▼               ▼
 Request Model   Environment    Assertion     Collection       Report
                                 Engine         Runner
     │                                             │
     └───────────────────┬─────────────────────────┘
                         ▼
                  Transport Adapter
                         │
             ┌───────────┴───────────┐
             ▼                       ▼
        Native Transport       Browser/Demo Adapter

                         ▲
                         │
                    MoonProbe CLI
```

## 为什么要有 Transport Adapter

HTTP 在 Native 与 Browser 环境中的限制不同。

- Native/CLI 可以直接访问目标网络；
- 浏览器受到 CORS 与浏览器安全模型限制；
- Demo 不应为了“能发所有请求”强制引入一个隐藏的云代理。

因此 Core 将请求描述、模板、断言、Collection 和报告与实际 Transport 解耦。

Web Demo 首版可以：

1. 调用允许 CORS 的公开测试 API；
2. 使用同源 Demo API；
3. 使用本地/可选 relay（若实现，必须明确标注）。

## 核心数据流

```text
Request Definition
      ↓
Resolve Environment
      ↓
Expand {{variables}}
      ↓
Transport.execute
      ↓
Response
      ↓
Assertions
      ↓
RequestResult
      ↓
CollectionResult
      ↓
Reporter
```

## 模块职责

### request

只描述请求，不执行网络。

### environment

存储变量并提供解析上下文。

### template

将字符串中的 `{{name}}` 替换成 Environment 中的值，并返回缺失变量错误。

### transport

负责实际 IO。Core 使用 `Transport` trait 隔离具体实现。

当前 Native 适配器位于 `transport/HttpTransport`，基于 `moonbitlang/async`；Core 本身不 import HTTP client。测试可以用 FakeTransport 完整替换网络层。

### assertion

将 Response 映射为稳定的 AssertionResult。

### collection

描述一组请求、执行顺序、每个请求的断言/timeout，以及 stop-on-failure 策略。未执行项通过 `skipped` 与失败项区分。

### runner

协调模板展开、Transport、断言和错误处理。`run_request` 返回 `RequestResult`；`run_collection` 在同一 Transport abstraction 上按声明顺序执行，并返回 `CollectionResult`。

### report

独立 `report/` 包把 `CollectionResult` 转换为 Text / JSON。JSON 报告带稳定 schema version；Reporter 不执行网络，也不依赖 CLI。

## 错误模型

预期至少区分：

- InvalidRequest
- MissingVariable
- TransportError
- Timeout
- InvalidResponse
- AssertionFailure
- CollectionError

错误必须进入结构化结果，不能只打印字符串。

## 可测试性

Transport 必须可替换为 FakeTransport：

```text
Request
  ↓
FakeTransport
  ↓
Predefined Response
  ↓
Assertion Engine
```

这样绝大多数 Core 测试不依赖真实网络。

## Web 与 Core 的边界

Playground 使用 HTML/CSS/JavaScript 完成交互和浏览器 `fetch`，但模板、断言与报告不在 JavaScript 重写。

为避免 CLI 与 Web 各自维护 JSON 语义，新增纯 MoonBit `wire/` 包：

```text
CLI JSON ───────┐
                ├─> wire.parse ─> Core models
Playground JSON ┘
```

浏览器通过 `playground_bridge/` 的 JS foreign-library 导出调用：

- `prepare_request_json`：wire parse + Environment + `core.render_request`；
- `evaluate_response_report_json`：Response 构造 + `core.evaluate_assertions` + `report.collection_report_json`。

浏览器网络 IO 由 `fetch` 完成，因此 CORS 约束被明确保留。Native CLI 仍走真正的 `HttpTransport`。

Playground 的 Run all 顺序循环属于 Browser Adapter；核心模板、断言判定和稳定 report schema 仍来自 MoonBit。
