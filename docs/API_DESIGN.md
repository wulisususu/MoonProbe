# MoonProbe 公共 API 设计草案

> 本文描述目标 API，不代表当前已实现。

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

目标形式：

```moonbit
let assertions = [
  status_is(200),
  header_exists("content-type"),
  json_exists("$.id"),
  json_equals("$.name", "Alice"),
  response_time_lt(500),
]
```

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
