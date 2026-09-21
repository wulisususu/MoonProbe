# MoonProbe 开发复盘

## 1. 为什么采用 Core-first

MoonProbe 没有采用“先做 UI，再补底层”的路线，而是按 Core → Transport → Collection → CLI → Web 的顺序推进。

开发目标不是只做一个比赛演示页，而是让删除 Web 后，剩余 MoonBit 代码仍然是完整、可测试、可复用的 API 测试工程。

## 2. 关键架构决策

### Core 不依赖真实网络

`core/` 只定义模型、模板、断言、Runner 与 Transport trait。真实 HTTP 位于独立 `transport/`。

这样绝大多数 Core 测试可用 FakeTransport 完成，Native 网络库不会侵入基础模型。

### Result 优先于打印字符串

单请求和 Collection 都返回结构化结果。Reporter 是结果的消费者，而不是 Runner 内部副作用。

因此 CLI、CI、Web 和后续 Agent Adapter 可以复用同一结果模型。

### 明确 continue / stop-on-failure

Collection 不把“没有执行”混成“执行失败”。

`CollectionResult` 显式区分 total / executed / passed / failed / skipped / stopped_early，避免 stop-on-failure 后的统计失真。

### CLI wire format 不进入 Core

Gate 6 准备 Web 时，如果直接在 JavaScript 重写一份 JSON parser，就会出现两套 wire semantics。

因此 parser 被抽到纯 MoonBit `wire/`，CLI 和 Web Bridge 共同消费。

### Browser 不伪装成 Native

浏览器网络能力天然受 CORS 限制，所以 Web Playground 没有隐藏代理，也没有声称可以任意访问私有 API。

Browser Adapter 使用 `fetch` 做 Host IO；Template、Assertion、Report 仍通过 MoonBit JS Bridge。

## 3. 开发 Gate

~~~text
Gate 0  Repository / Spec / CI
Gate 1  Core Models
Gate 2  Template + Assertions
Gate 3  Transport + Single Request
Gate 4  Collection Runner + Report
Gate 5  Native CLI
Gate 6  Web Playground + JS Bridge
Gate 7  Submission Hardening
~~~

每个 Gate 都要求代码、测试和文档同步推进。

## 4. 测试策略

### 黑盒 Core 测试

从公共 API 构造输入并检查结构化结果，避免测试只绑定内部实现。

### FakeTransport

Runner 的主要分支不依赖互联网：

~~~text
Request → FakeTransport → Response → Assertions → Result
~~~

### Native loopback integration

少量真实 HTTP 测试使用 CI 本地 loopback server，覆盖真实 IO 与 timeout，不把公共互联网稳定性变成核心测试前提。

### Browser Bridge ABI smoke

仅仅 `moon build --target js` 成功还不够。

CI 实际导入生成的 ESM，然后调用：

- `prepare_request_json`
- `evaluate_response_report_json`

用于验证导出名、字符串 ABI、模板展开、Assertion 和 Report 结构。

## 5. 被测试发现并纠正的问题

### JS 构建目录假设错误

初版脚本寻找 `target/js`，当前 MoonBit 工具链实际产物位于 `_build/js`。

新增 ABI smoke 后，该错误被发现并修复。

### Pages 不是“代码构建成功就等于上线”

GitHub Pages workflow 已能成功编译并 stage Playground，但仓库第一次创建 Pages site 需要仓库管理员权限。

Actions token 的 `pages: write` 无权完成首次站点启用，因此该步骤被记录为一次性的仓库 Settings 操作，而不是把“构建成功”误写成“线上已部署”。

## 6. AI 在开发中的位置

AI 被用作工程助手：实现草案、重构、测试扩展、构建错误诊断、文档和 UI 原型。

但项目目标、Core / Adapter 边界、测试是否有意义、许可证责任和最终合并决策由参赛者负责。

CI 失败被当作对假设的外部校准，而不是通过删除测试来绕过。

## 7. 当前局限

v0.1 有意不做：

- OAuth 完整流程；
- WebSocket / gRPC；
- 完整 JSONPath；
- Postman Collection 全兼容；
- 云同步和多人协作；
- Browser relay；
- 大规模负载测试。

比赛尾声不通过堆功能破坏当前模块边界。

## 8. 结论

MoonProbe 当前形态是：

~~~text
Reusable MoonBit testing core
        +
Native transport / CLI
        +
Thin browser adapter
~~~

即使移除 `playground/`，Core、Native Transport、CLI、Collection Runner、Reporter 和自动化测试仍然是完整可用的工程。
