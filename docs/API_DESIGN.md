# MoonProbe 公共 API 设计

> 当前实现状态：Core Models、模板展开、Assertion Engine、Transport、单请求 Runner、Collection Runner 与 Report 已实现。CLI 属于下一 Gate。

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

每个 Collection entry 自己携带 Request、Assertions 与 timeout：

```moonbit
let collection = @core.new_collection(
  "Todo API",
  [
    @core.collection_request(create_request, [@core.StatusIs(201)]),
    @core.collection_request(get_request, [@core.StatusIs(200)]),
  ],
  stop_on_failure=true,
)

let result = @core.run_collection(collection, env, transport)
```

`stop_on_failure=false` 是默认值。失败包括模板、Transport 或 Assertion 失败；开启 stop-on-failure 时会保留失败结果，并把后续请求计为 skipped。

```text
CollectionResult
├─ collection_name
├─ total
├─ executed
├─ passed
├─ failed
├─ skipped
├─ duration_ms
├─ stopped_early
└─ requests[]
```

`duration_ms` 是已执行请求由 Transport 报告的累计耗时，不混入 Runner 自身开销。

## Report

Reporter 位于独立 `report/` 包，只消费 `CollectionResult`：

```moonbit
let text = @report.collection_report_text(result)
let json = @report.collection_report_json(result)
```

JSON 顶层 schema 使用固定版本：

```text
moonprobe.collection-report.v1
```

这样 CLI、CI、Web Demo 或其他工具可以复用同一执行结果，而无需把格式化逻辑塞回 Core。

## API 设计原则

- 类型优先于字符串约定；
- Core 不打印 UI 文案；
- 错误可枚举、可匹配；
- Runner 不依赖具体网络实现；
- 测试中可以完全替换 Transport；
- Native Transport 放在适配层，不让网络库侵入 Core 模型；
- JSON 报告需要版本字段，为后续兼容留空间。
