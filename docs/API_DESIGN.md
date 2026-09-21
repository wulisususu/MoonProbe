# MoonProbe 公共 API 设计草案

> 本文同时记录当前公共 API 与后续目标。Core Models、模板展开及 MVP Assertion Engine 已实现；Runner / Transport 仍为目标设计。

## Request

目标：

```moonbit
let req = Request::new(GET, "https://api.example.com/users/{{user_id}}")
  .header("Authorization", "Bearer {{token}}")
  .query("include", "profile")
```

JSON Body：

```moonbit
let req = Request::post("{{base_url}}/todos")
  .json_body("{\"title\":\"MoonProbe\"}")
```

## Environment

```moonbit
let env = Environment::new()
  .set("base_url", "https://api.example.com")
  .set("token", "demo-token")
```

## Assertion

当前实现使用显式 Assertion 枚举：

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

首版 JSON Path 只支持对象路径：`# MoonProbe 公共 API 设计草案

> 本文同时记录当前公共 API 与后续目标。Core Models、模板展开及 MVP Assertion Engine 已实现；Runner / Transport 仍为目标设计。

## Request

目标：

```moonbit
let req = Request::new(GET, "https://api.example.com/users/{{user_id}}")
  .header("Authorization", "Bearer {{token}}")
  .query("include", "profile")
```

JSON Body：

```moonbit
let req = Request::post("{{base_url}}/todos")
  .json_body("{\"title\":\"MoonProbe\"}")
```

## Environment

```moonbit
let env = Environment::new()
  .set("base_url", "https://api.example.com")
  .set("token", "demo-token")
```

## Assertion

、`$.id`、`$.user.id`。数组索引与完整 JSONPath 语法不属于 v0.1。

## Runner

```moonbit
let result = run(request, env, assertions, transport)
```

结果不通过异常字符串表达，而返回结构化 RequestResult。

## Collection

```moonbit
let collection = Collection::new("Todo API")
  .add(create_todo)
  .add(get_todo)
  .add(update_todo)
  .add(delete_todo)

let report = run_collection(collection, env, transport)
```

## Result

预期结构：

```text
RequestResult
├─ request_name
├─ response
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

CollectionResult：

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
- JSON 报告需要版本字段，为后续兼容留空间。
