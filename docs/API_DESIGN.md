# MoonProbe 公共 API 设计

> 当前实现状态：Core Models、模板展开、MVP Assertion Engine、Transport abstraction 与单请求 Runner 已实现。Collection / Report / CLI 仍属于后续 Gate。

## Request

当前基础构造：

```moonbit
let req = @core.new_request(
  "Get user",
  @core.GET,
  "{{base_url}}/users/1",
)
```

完整 `Request` 还可以显式携带 Headers、Query、Body 与 Auth。

## Environment

```moonbit
let env = @core.environment([
  { name: "base_url", value: "https://api.example.com" },
  { name: "token", value: "demo-token" },
])
```

模板展开采用单次 `{{variable}}` 替换；缺失变量返回结构化 `MissingVariable(name)`。

## Assertion

当前使用显式 `Assertion` 枚举：

```moonbit
let assertions = [
  @core.StatusIs(200),
  @core.HeaderExists("content-type"),
  @core.JsonExists("$.id"),
  @core.JsonEquals("$.name", "Alice"),
  @core.ResponseTimeLessThan(500),
]

let results = @core.evaluate_assertions(assertions, response)
let passed = @core.assertions_passed(results)
```

首版 JSON Path 只支持对象路径：`$`、`$.id`、`$.user.id`。数组索引与完整 JSONPath 语法不属于 v0.1。

## Transport

Core 只依赖可替换 trait：

```moonbit
pub(open) trait Transport {
  async fn execute(
    Self,
    Request,
    timeout_ms : Int,
  ) -> Result[Response, ProbeError]
}
```

默认 Native 实现位于独立 `transport/` 包：

```moonbit
let transport = @transport.HttpTransport::new()
```

当前 `HttpTransport` 基于 `moonbitlang/async@0.22.1`，负责：

- HTTP / HTTPS 请求；
- Method 映射；
- RFC 3986 Query 参数编码；
- Bearer / Basic Auth；
- JSON / Text Body；
- Response status / headers / body / duration；
- timeout 与 transport error 映射。

## Runner

单请求执行已经形成完整协调链路：

```moonbit
let result = @core.run_request(
  request,
  env,
  assertions,
  @transport.HttpTransport::new(),
  timeout_ms=10000,
)
```

执行顺序：

```text
Request
  ↓
render_request
  ↓
Transport.execute
  ↓
Response
  ↓
evaluate_assertions
  ↓
RequestResult
```

`RequestResult` 不依赖打印字符串表达失败：

```text
RequestResult
├─ request_name
├─ response?
│  ├─ status
│  ├─ headers
│  ├─ body
│  └─ duration_ms
├─ assertions[]
│  ├─ passed
│  ├─ expected
│  ├─ actual
│  └─ message
└─ error?
```

## Collection

Gate 4 目标：

```moonbit
let report = run_collection(collection, env, transport)
```

预计输出：

```text
CollectionResult
├─ total
├─ passed
├─ failed
├─ duration
└─ requests[]
```

## API 设计原则

- 类型优先于字符串约定；
- Core 不打印 UI 文案；
- 错误可枚举、可匹配；
- Runner 不依赖具体网络实现；
- 测试中可以完全替换 Transport；
- Native Transport 放在适配层，不让网络库侵入 Core 模型；
- JSON 报告需要版本字段，为后续兼容留空间。
