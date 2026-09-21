# MoonProbe Demo 设计

## Demo 的唯一目标

让第一次看到项目的人在 **10 秒内**知道：

> MoonProbe 是一个 API 调试与自动化测试工具。

不能要求评委先读架构文档才能理解项目。

## 第一屏

```text
MoonProbe
API Debugging & Testing, powered by MoonBit

┌──────────────┬────────────────────────────┬──────────────────┐
│ Collections  │ GET {{base_url}}/todos/1  │ Response         │
│              │                    [Send]  │                  │
│ Todo API     │ Params Headers Auth Body   │ 200 OK           │
│ ├ Create     │                            │ 42 ms            │
│ ├ List       │                            │                  │
│ ├ Get        │                            │ { "id": 1, ... } │
│ ├ Update     │                            │                  │
│ └ Delete     │                            │                  │
├──────────────┴────────────────────────────┴──────────────────┤
│ Assertions: ✓ status = 200  ✓ $.id exists                   │
└──────────────────────────────────────────────────────────────┘
```

## 必须有的交互

### Send

用户修改 URL 或 Body 后点击 Send。

### Run Collection

一键运行：

```text
✓ Create Todo    201  82ms
✓ List Todos     200  49ms
✓ Get Todo       200  41ms
✗ Update Todo    500  71ms
✓ Delete Todo    204  37ms

4 / 5 passed
```

### 查看失败

点击失败项：

```text
Expected: status == 200
Actual:   500

Response:
{
  "error": "internal error"
}
```

## 预置场景

### Scenario A — Todo API

最容易理解的主 Demo。

### Scenario B — Auth Flow

后续扩展项。当前 Request Builder 已支持 Bearer / Basic Auth wire format，但默认公开 Demo 不依赖真实账号。

### Scenario C — AI-generated API regression

后续叙事场景。首版先把通用 Todo API 调试与回归流程做完整，不让 AI 成为项目主体。

## Demo 与 Core 的关系

页面明确标注：

> MoonBit Core · Browser Fetch Adapter

当前浏览器边界：

```text
UI builds Request JSON
      ↓
MoonBit wire.parse
      ↓
MoonBit core.render_request
      ↓
Browser fetch (CORS applies)
      ↓
MoonBit core.evaluate_assertions
      ↓
MoonBit report.collection_report_json
```

CLI 与 Playground 共用 `wire/` JSON 输入语义、Environment 模板、Assertion Engine 和 Report schema。浏览器的实际网络 IO 由 host `fetch` 承担；Native CLI 使用 `HttpTransport`。

一键 Collection 的顺序循环位于 Browser Adapter；每个请求的模板与结果判定仍回到 MoonBit Core。这样不假装浏览器具备 Native Transport 能力，也不在 UI 复制断言规则。

## 浏览器网络限制

Web Demo 必须诚实处理 CORS：

- 默认使用允许跨域或同源的 Demo API；
- 若使用 relay/proxy，必须在界面和文档说明；
- 不宣传浏览器版可以无条件访问任意私有 API；
- Native CLI 承担真正的通用网络调试场景。

## 视觉原则

- 不做复杂营销页；
- 主屏就是工具；
- URL 输入框与 Send 按钮必须是视觉焦点；
- Response 和 Tests 必须同时可见；
- 比赛期间优先功能完整度，不追求大量动画。
