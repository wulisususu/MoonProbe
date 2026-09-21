# MoonProbe · 九月黑客松最终提交包

> 本文件用于报名、验收和最终提交时直接复制内容。个人身份字段保留为空，不在公开仓库中记录手机号、身份证号等隐私信息。

## 官方入口

- 赛事官网：https://moonbitlang.github.io/Hackathon2026/
- 飞书报名：https://bxup9uklfcb.feishu.cn/share/base/form/shrcnWUMlgpbwHaXgzV7HmNhNhg
- 正式章程：https://bxup9uklfcb.feishu.cn/wiki/Dx4Bwd6D1i3GfHkajQCcF7SznEd
- 赛事交流群：https://work.weixin.qq.com/gm/5b6b92c8677d0555f3fb6a3f1a081399
- 赛事小助手：https://u.wechat.com/EA2rUlkjobqjS4EeOCKuKdY

本期九月赛时间：**9 月第一周—2026-09-30**。报名与项目验收均在 9 月 30 日截止。

## 基本信息

| 字段 | 建议填写 |
| --- | --- |
| 项目名称 | MoonProbe |
| 英文副标题 | MoonBit-native API Testing Workbench |
| GitHub | https://github.com/wulisususu/MoonProbe |
| GitHub ID | wulisususu |
| 项目类型 | 新项目 |
| 推荐方向 | 开发者工具 / 工具库 |
| License | Apache-2.0 |
| 当前版本 | 0.1.0 |
| Mooncakes | 待发布：wulisususu/moonprobe@0.1.0 |
| 在线 Demo | 待 GitHub Pages 首次启用后填写 |
| 一页项目说明 | docs/PROJECT_PROPOSAL.md |
| Reviewer Guide | docs/REVIEWER_GUIDE.md |
| AI 使用说明 | docs/AI_USAGE.md |
| 开发复盘 | docs/DEVELOPMENT_RETROSPECTIVE.md |

个人姓名、手机号、邮箱、学校/单位等字段请在报名表中本人填写，不提交到公开仓库。

## 一句话项目介绍

**MoonProbe 是一个 MoonBit 原生 API 调试与自动化测试工具，把 Request、Environment、Assertion、Collection Runner 与 Report 做成可复用核心，并提供 Native CLI 与 Web Playground 两个参考适配层。**

## 100 字以内版本

MoonProbe 是 MoonBit 原生 API 调试与回归测试工具，支持真实 HTTP 请求、环境变量、结构化断言、Collection 批量执行、Text/JSON 报告、Native CLI 与 Web Playground。核心测试逻辑由 MoonBit 实现，UI 仅作为参考适配层。

## 项目说明（报名表长文本版）

MoonProbe 是一个以 MoonBit 为主要实现语言的 API 调试与自动化测试 Workbench。项目解决的是一个非常直接的开发问题：接口代码生成或修改完成后，开发者仍然需要真实发送请求、检查状态码和响应内容，并在后续修改中持续确认旧接口没有发生回归。

MoonProbe 将 Request / Response、Environment、`{{variable}}` 模板展开、Assertion Engine、Collection Runner 与结构化 Report 实现为可复用的 MoonBit 核心。Native 侧通过可替换的 Transport abstraction 接入真实 HTTP/HTTPS；CLI 支持单请求 `send`、Collection `run`、环境变量文件、Text/JSON 输出以及稳定退出码。Web Playground 则通过 MoonBit JavaScript Bridge 复用相同的 JSON wire parser、模板展开、断言和 Report，浏览器 JavaScript 只负责 `fetch`、超时控制与界面状态。

当前 v0.1 已完成 GET / POST / PUT / PATCH / DELETE / HEAD / OPTIONS、Query、Headers、JSON/Text Body、Bearer/Basic Auth、Response timing、多类 Assertions、continue/stop-on-failure Collection、versioned JSON Report、Native CLI、五请求 Todo Demo，以及 Linux/Windows CI。浏览器 Bridge 还额外通过 JavaScript target 编译和 Node ESM 实际导入调用验证。

项目没有把 Web UI 当成主体。即使删除 `playground/`，Core、Native Transport、Collection Runner、Reporter、CLI 和自动化测试仍然可以独立运行。MoonProbe 使用 Apache-2.0，第三方依赖与 AI 使用过程均有独立文档说明。

## 项目目标 / 解决的问题

MoonProbe 主要解决：

1. API 写出来以后缺少快速、确定性的行为验证；
2. GUI 调试、脚本和 CI 容易各自维护不同验证逻辑；
3. 多接口修改后缺少轻量级回归测试；
4. AI Coding 时代代码生成更快，但验证环节仍需要清晰证据；
5. MoonBit 生态缺少一套可复用的 API Request / Assertion / Collection 基础能力。

## 当前功能范围

已实现：

- HTTP Methods：GET / POST / PUT / PATCH / DELETE / HEAD / OPTIONS
- Query Params / Headers
- JSON / Text Body
- Bearer / Basic Auth
- Environment + `{{variable}}`
- Response status / headers / body / duration
- status / range / header / body / JSON / timing Assertions
- replaceable Transport
- Native HTTP Transport
- Single Request Runner
- ordered Collection Runner
- continue-on-failure / stop-on-failure
- Text Reporter
- versioned JSON Reporter：`moonprobe.collection-report.v1`
- Native CLI
- Web Playground
- Linux / Windows CI
- JavaScript Bridge ABI smoke test

明确不做：

- 完整 Postman 兼容
- OAuth 完整流程
- WebSocket / gRPC
- 完整 JSONPath
- 云同步 / 多人协作
- Browser relay
- 负载测试

## MoonBit 的核心价值

MoonBit 不是外围胶水，而负责项目的主要可复用逻辑：

- 公共 Request / Response / Environment 模型
- Template Engine
- Assertion Engine
- Collection Runner
- Result Model
- Text / JSON Reporter
- Native HTTP Transport
- CLI wire parsing
- CLI execution coordination
- Browser JavaScript foreign-library Bridge
- 单元 / 集成 / 回归测试

Web Playground 不复制 Template、Assertion 或 Report 算法。

## AI 使用说明

AI 用于代码实现建议、重构、测试补全、CI 故障诊断、UI 原型和文档整理。

参赛者负责：

- 确定项目方向和 Scope
- 判断 Core / Adapter 边界
- 审核公共 API
- 判断测试是否真正验证需求
- 处理第三方许可证与发布责任
- 接受或拒绝 AI 修改
- 对最终提交代码负责

详细证据：`docs/AI_USAGE.md` 与 `docs/DEVELOPMENT_RETROSPECTIVE.md`。

## 可复现验证

~~~bash
moon update
moon check --target native --deny-warn
moon test --target native
moon build --target native
~~~

公开 API 单请求：

~~~bash
moon run cmd/moonprobe -- send examples/requests/get-user.json \
  --env examples/env/public-demo.json \
  --format text
~~~

Collection：

~~~bash
moon run cmd/moonprobe -- run examples/collections/todo-api.json \
  --env examples/env/public-demo.json \
  --format json
~~~

## 评委最短验证路径

优先给评委以下四个入口：

1. README：快速理解项目是什么；
2. `docs/REVIEWER_GUIDE.md`：60 秒验证；
3. `docs/PROJECT_PROPOSAL.md`：一页项目说明；
4. Web Playground：可视化演示。

## 最终提交前仍需本人完成

- [ ] 在官方飞书表单填写个人信息；
- [ ] 确认已经加入赛事交流群；
- [ ] Settings → Pages → Source = GitHub Actions；
- [ ] 手动运行 `pages` workflow；
- [ ] 将真实 Demo URL 回填 README 和本文件；
- [ ] 截取最终演示截图；
- [ ] 创建 GitHub `v0.1.0` tag / Release；
- [ ] 登录 mooncakes.io 后执行 `moon publish`（若决定发布）；
- [ ] 在 2026-09-30 前完成报名与验收材料提交。

## 不要在报名材料中这样描述

避免：

> “这是一个类似 Postman 的网页工具。”

这会弱化 MoonBit 核心价值。

推荐：

> “MoonProbe 是 MoonBit-native API Testing Workbench。Web Playground 让功能直观可见，但真正可复用的主体是 MoonBit 实现的 Request/Environment/Assertion/Collection/Report 核心与 Native Transport。”
