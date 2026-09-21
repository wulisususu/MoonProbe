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

负责实际 IO。Core 使用接口/trait 隔离具体实现。

### assertion

将 Response 映射为稳定的 AssertionResult。

### collection

描述一组请求、执行顺序和每个请求的断言。

### runner

协调模板展开、Transport、断言和错误处理。

### report

把执行结果转换为 Text / JSON 等表示。

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

Playground 允许使用 TypeScript/HTML/CSS 完成交互层，但：

- 请求模型来自 Core；
- 模板规则来自 Core；
- Assertions 来自 Core；
- Collection Runner 来自 Core；
- 结构化报告来自 Core。

比赛阶段优先确保 MoonBit 代码是项目主体。
