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

Login 获取 token，然后后续请求使用 `{{token}}`。

用于展示 Environment / Template 的价值。

### Scenario C — AI-generated API regression

展示 AI 修改后，一个旧接口断言失败。

用于解释 AI Coding 时代的价值，但不让 AI 成为项目主体。

## Demo 与 Core 的关系

页面应明确标注：

> The same MoonBit Core powers the CLI and this playground.

并展示极短代码：

```moonbit
let report = @moonprobe.run_collection(collection, env)
```

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
