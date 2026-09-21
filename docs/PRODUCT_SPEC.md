# MoonProbe 产品规格

## 1. 用户是谁

首版主要服务三类用户：

1. **后端 / 全栈开发者**：开发接口后快速验证请求和响应；
2. **AI Coding 用户**：让 AI 生成接口后，用确定性的 Collection 验证功能是否真的可用；
3. **CI / 工具开发者**：希望用结构化 API 调用 MoonProbe Runner，而不是依赖 GUI。

## 2. 核心用户故事

### 手动调试

用户输入：

- Method
- URL
- Query Params
- Headers
- Auth
- Body

点击 Send 后看到：

- HTTP Status
- Response Headers
- Response Body
- Duration
- Assertion Results

### 保存请求

用户可以将请求保存到 Collection：

```text
Todo API
├─ Create Todo
├─ List Todos
├─ Get Todo
├─ Update Todo
└─ Delete Todo
```

### 一键回归

点击 Run Collection：

```text
✓ Create Todo      201   82ms
✓ List Todos       200   49ms
✓ Get Todo         200   41ms
✗ Update Todo      500   71ms
✓ Delete Todo      204   37ms

4 passed / 1 failed
```

## 3. 为什么不是普通 HTTP Client

普通 HTTP Client 解决的是“发送一个请求”。

MoonProbe 的核心价值是：

```text
Request
  +
Environment
  +
Assertions
  +
Collection
  +
Runner
  +
Report
```

同一份 Collection 可以从 GUI、CLI、CI 或其他 MoonBit 程序调用。

## 4. MVP 功能

### Request Builder

- GET / POST / PUT / PATCH / DELETE
- Query Params
- Headers
- JSON Body
- Text Body
- Bearer Token
- Basic Auth

### Environment

支持：

```text
{{base_url}}
{{token}}
{{user_id}}
```

环境变量可用于：

- URL
- Header
- Query
- Body

### Assertions

首版计划支持：

- status equals
- status in range
- header exists
- header contains
- body contains
- JSON path exists
- JSON path equals
- response time less than

### Collection Runner

- 顺序执行
- 单项失败记录
- stop-on-failure 可选
- 结构化执行结果
- Text / JSON report

## 5. 非目标

MoonProbe 首版不是：

- Postman 全功能替代；
- API 文档托管平台；
- 后端 Mock Cloud；
- 团队协作 SaaS；
- 网络抓包器；
- 完整性能压测平台。

## 6. AI Coding 场景

AI Agent 可以调用：

```text
moonprobe run todo-api.collection
```

得到：

```json
{
  "passed": 4,
  "failed": 1,
  "failures": [
    {
      "request": "Update Todo",
      "assertion": "status == 200",
      "actual": 500
    }
  ]
}
```

Agent 不需要根据自然语言猜测测试结果，可以直接读取确定性报告。

## 7. 成功标准

一个不了解项目的开发者打开 Demo 后，应在 10 秒内理解：

> 这是一个 API 调试与自动化测试工具。

一个 MoonBit 开发者阅读 Core API 后，应能理解：

> 我可以不使用 Web UI，只 import Runner / Assertion / Collection 能力。
