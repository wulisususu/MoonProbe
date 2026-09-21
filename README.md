# MoonProbe

> **MoonBit-native API debugging and automated testing workbench**  
> 用 MoonBit 驱动的 API 调试、集合执行与自动化断言工具。

MoonProbe 的目标很简单：让开发者像使用常见 API 调试工具一样，输入 URL、选择方法、填写参数并发送请求；同时把 **Request Model、Environment、Template、Assertion、Collection Runner、Report** 做成可复用的 MoonBit 核心能力。

> 当前状态：**Gate 1–6 已完成，Gate 7 提交前验收进行中**。Core、Native Transport、Collection Runner、Text/JSON Report、Native CLI 与 MoonBit-backed Web Playground 均已实现；Native 走 Linux / Windows CI，Playground Bridge 额外通过 JS target 与 Node ABI 冒烟测试。

## 一句话说明

如果你开发了一个后端接口，例如：

```text
POST /login
GET  /users/:id
PATCH /users/:id
```

MoonProbe 可以帮你：

1. 手动发送请求，立即查看状态码、Header、Body 和耗时；
2. 把多个请求保存成 Collection；
3. 用 `{{token}}`、`{{base_url}}` 之类的环境变量复用配置；
4. 给响应加断言，例如“状态码必须是 200”“JSON 中必须存在 user.id”；
5. 一键运行整个 Collection，得到通过/失败报告；
6. 未来可供 CLI、CI 和 AI Coding Agent 直接调用同一套 MoonBit 核心 API。

## 为什么做这个

AI 编程让 API 生成越来越快，但“代码生成了”并不等于“接口真的能工作”。

MoonProbe 希望把这个验证过程变得非常直接：

```text
AI / Developer writes API
        ↓
MoonProbe sends requests
        ↓
Assertions verify behavior
        ↓
Collection report shows failures
        ↓
Developer / Agent fixes the API
```

它首先是一个人人能看懂的 API 调试工具，同时也是一个可被其他 MoonBit 项目复用的测试引擎。

## 产品形态

当前 Playground 第一屏直接展示：

```text
┌───────────────┬───────────────────────────────┬───────────────┐
│ Collections   │ GET  https://api.example.com │ Response      │
│               │                     [ SEND ]  │               │
│ User API      │ Params Headers Auth Body      │ 200 OK        │
│ ├ Login       │                               │ 83 ms         │
│ ├ Get User    │ { "id": 1 }                  │               │
│ └ Update User │                               │ { ... }       │
├───────────────┴───────────────────────────────┴───────────────┤
│ Tests:  ✓ status == 200   ✓ body.user.id exists              │
└───────────────────────────────────────────────────────────────┘
```

评委不需要先理解抽象概念：看到 URL、GET/POST、SEND、Response，就知道它是 API 调试/测试工具。

## MoonBit Core

当前公共核心能力：

```text
core/
├─ request/       # Method / URL / headers / body / auth
├─ response/      # status / headers / body / timing
├─ environment/   # {{variable}} 环境变量
├─ template/      # 请求模板展开
├─ assertion/     # 响应断言
├─ collection/    # 请求集合与执行顺序
├─ runner/        # 单请求 / 集合执行
└─ report/        # 结构化测试报告
```

原则：删除 Web Playground 后，MoonProbe Core 仍然必须是一个完整、可测试、可复用的 MoonBit 项目。

## MVP 范围

九月赛 MVP 只聚焦以下能力：

- HTTP methods：GET / POST / PUT / PATCH / DELETE
- Query Params
- Headers
- JSON / Text Body
- Bearer Token / Basic Auth
- Response status / headers / body / timing
- `{{variable}}` 环境变量
- Collection
- Assertions
- Collection Runner
- JSON/Text Report
- CLI
- Web Playground / Demo

明确不在首版范围：

- 完整 Postman 兼容
- OAuth 全流程
- gRPC
- WebSocket
- 云同步
- 多人协作
- 插件市场

## 当前最小执行 API

单请求执行已经打通模板、HTTP Transport 和断言：

```moonbit
let request = @core.new_request(
  "Get user",
  @core.GET,
  "{{base_url}}/users/1",
)

let result = @core.run_request(
  request,
  env,
  [
    @core.StatusIs(200),
    @core.JsonExists("$.id"),
  ],
  @transport.HttpTransport::new(),
)
```

`HttpTransport` 当前基于 `moonbitlang/async`，支持 Query 参数 RFC 3986 编码、Bearer / Basic Auth、JSON / Text Body、响应耗时以及结构化 timeout / transport error。

## Collection Runner 与报告

Collection 会按声明顺序执行，并为每个请求保存自己的 Assertions 与 timeout：

```moonbit
let collection = @core.new_collection(
  "Todo API",
  [
    @core.collection_request(create_request, [@core.StatusIs(201)]),
    @core.collection_request(get_request, [@core.StatusIs(200)]),
  ],
  stop_on_failure=true,
)

let result = @core.run_collection(
  collection,
  env,
  @transport.HttpTransport::new(),
)

let text = @report.collection_report_text(result)
let json = @report.collection_report_json(result)
```

`CollectionResult` 会区分 `total / executed / passed / failed / skipped`，因此 stop-on-failure 后尚未执行的请求不会被误算成失败。JSON 报告使用稳定 schema 标识 `moonprobe.collection-report.v1`。

## 仓库结构

```text
MoonProbe/
├─ core/                     # MoonBit 公共核心（项目主体）
├─ transport/                # Native HTTP Transport
├─ report/                   # Text / JSON Reporter
├─ cli/                      # MoonBit CLI
├─ wire/                     # CLI / Playground 共用 JSON wire parser
├─ playground_bridge/        # MoonBit → JS bridge
├─ examples/                 # 可运行示例
├─ tests/                    # 跨模块测试 / fixtures
├─ playground/               # Web Demo，参考应用
├─ docs/
│  ├─ PROJECT_PROPOSAL.md
│  ├─ PRODUCT_SPEC.md
│  ├─ PROJECT_SCOPE.md
│  ├─ ARCHITECTURE.md
│  ├─ API_DESIGN.md
│  ├─ DEVELOPMENT_PLAN.md
│  ├─ TEST_PLAN.md
│  ├─ DEMO_PLAN.md
│  ├─ AI_USAGE.md
│  ├─ DEVELOPMENT_RETROSPECTIVE.md
│  ├─ THIRD_PARTY.md
│  └─ COMPETITION_CHECKLIST.md
├─ CONTRIBUTING.md
├─ CHANGELOG.md
└─ LICENSE
```

## 安装与验证

需要 MoonBit 工具链。克隆仓库后：

```bash
moon update
moon check --target native --deny-warn
moon test --target native
moon build --target native
```

## CLI

直接通过 MoonBit 运行：

```bash
moon run cmd/moonprobe -- --help
moon run cmd/moonprobe -- --version
```

发送单个请求：

```bash
moon run cmd/moonprobe -- send examples/requests/get-user.json \
  --env examples/env/dev.json \
  --format text
```

执行 Collection 并输出机器可读 JSON：

```bash
moon run cmd/moonprobe -- run examples/collections/todo-api.json \
  --env examples/env/dev.json \
  --format json
```

示例中的 `base_url` / token 是模板值；实际执行前请在 `examples/env/dev.json` 中替换为你自己的测试 API。

CLI 退出码：

- `0`：请求/Collection 及全部断言通过；
- `1`：请求已执行，但网络、响应或断言结果失败；
- `2`：命令参数、JSON 输入文件或环境配置无效。

完整 CLI JSON 格式见 [docs/CLI.md](docs/CLI.md)。

## Web Playground

`playground/` 是参考 UI，不重新实现 MoonBit 的模板、断言和 Report：

```text
Browser UI / fetch
      ↓
MoonBit JS Bridge
      ↓
wire.parse
core.render_request
core.evaluate_assertions
report.collection_report_json
```

Playground 提供：

- Method + URL + Send；
- Body / Headers / Params / Auth / Tests 编辑；
- Response status / body / duration；
- Assertion 逐项通过/失败；
- 5 请求 Todo Collection；
- 一键顺序 Run all；
- 可编辑 `base_url` Environment。

默认 Demo API 使用 CORS-friendly 的 JSONPlaceholder。浏览器仍受 CORS 限制；真正的任意网络访问由 Native CLI 承担。

GitHub Pages workflow 已在 `main` 上配置，会自动构建 MoonBit JS Bridge 并 stage Playground。仓库首次上线仍需一次性在 Settings → Pages 中把 Source 设为 GitHub Actions。

## 赛事

MoonProbe 计划参加 **2026 MoonBit 黑客松 · 九月赛**。

项目从第一天按照以下要求组织：

- MoonBit 为主要实现语言；
- 仓库公开；
- 保留连续 commits / Issues / PR；
- 提供清晰 README；
- 提供可运行示例与必要测试；
- 使用 OSI 认可的开源许可证；
- AI 可以辅助开发，但技术目标、路径、测试与质量由参赛者掌握；
- 不把已有作品拆分或重复提交。

赛事准备与验收跟踪见 [docs/COMPETITION_CHECKLIST.md](docs/COMPETITION_CHECKLIST.md)。

## 文档导航

- [一页项目申报说明](docs/PROJECT_PROPOSAL.md)
- [产品需求与用户体验](docs/PRODUCT_SPEC.md)
- [项目范围](docs/PROJECT_SCOPE.md)
- [系统架构](docs/ARCHITECTURE.md)
- [公共 API 设计](docs/API_DESIGN.md)
- [开发计划](docs/DEVELOPMENT_PLAN.md)
- [测试计划](docs/TEST_PLAN.md)
- [CLI 使用与 JSON 格式](docs/CLI.md)
- [Demo 设计](docs/DEMO_PLAN.md)
- [AI 使用说明](docs/AI_USAGE.md)
- [开发复盘](docs/DEVELOPMENT_RETROSPECTIVE.md)
- [第三方依赖与许可证](docs/THIRD_PARTY.md)
- [赛事验收清单](docs/COMPETITION_CHECKLIST.md)
- [贡献指南](CONTRIBUTING.md)
- [变更记录](CHANGELOG.md)

## License

Apache License 2.0. See [LICENSE](LICENSE).
