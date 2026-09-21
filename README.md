# MoonProbe

> **MoonBit-native API debugging and automated testing workbench**  
> 用 MoonBit 驱动的 API 调试、集合执行与自动化断言工具。

MoonProbe 的目标很简单：让开发者像使用常见 API 调试工具一样，输入 URL、选择方法、填写参数并发送请求；同时把 **Request Model、Environment、Template、Assertion、Collection Runner、Report** 做成可复用的 MoonBit 核心能力。

> 当前状态：**Gate 1 已完成，Gate 2 进行中**。`{{variable}}` 模板展开和 Request 全字段渲染已经实现并通过 Linux / Windows CI；下一步进入 Assertion Engine。

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

最终 Demo 的第一屏会非常直接：

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

计划中的公共核心模块：

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

## 计划中的最小 API

> 以下为设计草案，最终 API 会随着测试和实现迭代。

```moonbit
let request = @moonprobe.Request::get("https://api.example.com/users/1")
  .header("Authorization", "Bearer {{token}}")

let result = @moonprobe.run(request, env)

let checks = [
  @moonprobe.status_is(200),
  @moonprobe.json_exists("$.id"),
]
```

Collection：

```moonbit
let report = @moonprobe.run_collection(collection, env)
```

## 仓库结构

```text
MoonProbe/
├─ core/                     # MoonBit 公共核心（项目主体）
├─ cli/                      # MoonBit CLI
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
│  └─ COMPETITION_CHECKLIST.md
├─ CONTRIBUTING.md
├─ CHANGELOG.md
└─ LICENSE
```

## 开发与验证目标

最终仓库至少应支持：

```bash
moon check
moon test
moon build
```

并提供一个从零可复现的示例 Collection。

CLI 目标形式：

```bash
moonprobe send examples/requests/get-user.json
moonprobe run examples/collections/todo-api.json
moonprobe run examples/collections/todo-api.json --format json
```

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
- [Demo 设计](docs/DEMO_PLAN.md)
- [AI 使用说明](docs/AI_USAGE.md)
- [赛事验收清单](docs/COMPETITION_CHECKLIST.md)
- [贡献指南](CONTRIBUTING.md)
- [变更记录](CHANGELOG.md)

## License

Apache License 2.0. See [LICENSE](LICENSE).
