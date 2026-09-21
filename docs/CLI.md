# MoonProbe CLI

MoonProbe CLI 是 Core / Transport / Reporter 的薄适配层。它负责读取 argv 和 JSON 文件，但不重新实现 HTTP、断言或 Collection Runner。

## 命令

```bash
moon run cmd/moonprobe -- --help
moon run cmd/moonprobe -- --version

moon run cmd/moonprobe -- send request.json
moon run cmd/moonprobe -- run collection.json

moon run cmd/moonprobe -- run collection.json \
  --env env.json \
  --format json
```

`--format` 可取 `text` 或 `json`，默认 `text`。

## 退出码

| Code | Meaning |
| --- | --- |
| 0 | 请求/Collection 与全部断言通过 |
| 1 | 请求已经执行，但 Transport、Response 或 Assertion 结果失败 |
| 2 | 参数、文件读取、JSON 输入或配置错误 |

## Request JSON

最小文件：

```json
{
  "name": "Health",
  "method": "GET",
  "url": "{{base_url}}/health"
}
```

完整示例：

```json
{
  "name": "Create todo",
  "method": "POST",
  "url": "{{base_url}}/todos",
  "headers": [
    { "name": "Accept", "value": "application/json" }
  ],
  "query": [
    { "name": "draft", "value": "false" }
  ],
  "body": {
    "title": "MoonProbe"
  },
  "auth": {
    "type": "bearer",
    "token": "{{token}}"
  },
  "timeout_ms": 5000,
  "assertions": [
    { "type": "status_between", "min": 200, "max": 299 },
    { "type": "json_exists", "path": "$.id" }
  ]
}
```

Body 规则：

- 缺失/null：Empty；
- JSON string：Text body；
- object/array/number/bool：序列化为 JSON body。

Auth：

```json
{ "type": "none" }
```

```json
{ "type": "bearer", "token": "{{token}}" }
```

```json
{
  "type": "basic",
  "username": "{{username}}",
  "password": "{{password}}"
}
```

## Assertions

支持以下 wire 格式：

```json
{ "type": "status_is", "expected": 200 }
{ "type": "status_between", "min": 200, "max": 299 }
{ "type": "header_exists", "name": "content-type" }
{ "type": "header_contains", "name": "content-type", "value": "json" }
{ "type": "body_contains", "value": "MoonProbe" }
{ "type": "json_exists", "path": "$.id" }
{ "type": "json_equals", "path": "$.id", "expected": 1 }
{ "type": "response_time_less_than", "ms": 500 }
```

当前 JSON Path 仍遵循 Core v0.1 约束，只支持对象路径如 `$`、`$.id`、`$.user.id`。

## Collection JSON

```json
{
  "name": "Todo API",
  "stop_on_failure": true,
  "requests": [
    {
      "name": "List todos",
      "method": "GET",
      "url": "{{base_url}}/todos",
      "assertions": [
        { "type": "status_is", "expected": 200 }
      ]
    },
    {
      "name": "Create todo",
      "method": "POST",
      "url": "{{base_url}}/todos",
      "body": {
        "title": "MoonProbe"
      },
      "assertions": [
        { "type": "status_between", "min": 200, "max": 299 }
      ]
    }
  ]
}
```

每个 request 都可有自己的 `timeout_ms` 和 `assertions`。未指定 `stop_on_failure` 时默认继续执行后续请求。

## Environment JSON

Environment 是简单字符串字典。仓库提供两个示例：

`examples/env/public-demo.json` 可直接用于公开演示：

```json
{
  "base_url": "https://jsonplaceholder.typicode.com",
  "token": "moonprobe-public-demo"
}
```

`examples/env/dev.json` 则作为自有 API 配置模板：

```json
{
  "base_url": "https://api.example.com",
  "token": "replace-me"
}
```

文件中的所有值必须是字符串。模板展开由 Core 完成，因此 URL、Header、Query、Body 和 Auth 都遵循同一套 `{{variable}}` 规则。

## JSON Output

`--format json` 使用 Reporter 的稳定 schema：

```text
moonprobe.collection-report.v1
```

这使 CLI 输出可直接交给 CI、脚本或后续 Web/Agent Adapter 消费，而不需要解析人类可读文本。
