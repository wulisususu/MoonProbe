# MoonProbe 一页项目申报说明

## 项目名称

**MoonProbe — MoonBit-native API Testing Workbench**

## 项目定位

MoonProbe 是一个以 MoonBit 为主要实现语言的 API 调试与自动化测试工具。它把 Request / Response、Environment、Template、Assertion、Collection Runner 与 Report 做成可复用的 MoonBit 核心能力，并在其上提供 Native CLI 和 Web Playground 两个适配层。

项目不以复刻完整 Postman 为目标，而聚焦于一个边界清晰的问题：

> **用一套 MoonBit 原生模型与验证逻辑，完成 API 手动调试、批量回归测试和机器可读验证。**

## 真实需求

AI 编程显著降低了接口生成成本，但“代码生成完成”不等于“接口行为正确”。开发者仍需要确认：

- 请求是否能真实发送；
- 状态码、Header 和 JSON 字段是否符合预期；
- 多接口修改后是否产生回归；
- timeout / transport error 是否被明确表达；
- 同一套验证能否在 CLI、CI 与可视化 Demo 中复用。

MoonProbe 将这些判断集中到结构化 Request / Assertion / Result 模型中，避免 GUI、脚本和 CI 各自维护一套规则。

## 当前已实现能力

v0.1 已实现：

1. GET / POST / PUT / PATCH / DELETE / HEAD / OPTIONS；
2. Query Params、Headers、JSON / Text Body；
3. Bearer Token 与 Basic Auth；
4. Response status / headers / body / timing；
5. `{{variable}}` Environment 与模板展开；
6. status / header / body / JSON / response-time Assertions；
7. Collection 与顺序 Runner；
8. continue-on-failure / stop-on-failure；
9. Text / versioned JSON Report；
10. Native HTTP Transport；
11. Native CLI：`send` / `run` / `--env` / `--format`；
12. MoonBit-backed Web Playground；
13. Linux / Windows Native CI；
14. JavaScript target Bridge 与 Node ABI 冒烟测试。

## 技术结构

~~~text
                         MoonProbe Core
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
   Request/Environment    Assertion Engine   Collection Runner
          │                   │                   │
          └───────────────────┼───────────────────┘
                              ▼
                       CollectionResult
                              │
                         Text/JSON Report
                              │
               ┌──────────────┴──────────────┐
               ▼                             ▼
          Native CLI                 Web Playground
               │                             │
       HttpTransport                  Browser fetch
                                             │
                                  MoonBit JS Bridge
~~~

CLI 与 Playground 共用 `wire/` JSON parser。Web 不复制模板、断言和报告算法；浏览器只承担 CORS 约束下的网络 IO 和界面编排。

## MoonBit 在项目中的角色

MoonBit 实现：

- Request / Response / Environment 等公共模型；
- 模板展开；
- Assertion Engine；
- Collection Runner；
- Text / JSON Reporter；
- Native HTTP Transport；
- CLI 输入与执行协调；
- CLI / Playground 共用 wire parser；
- JavaScript foreign-library Bridge；
- 单元、集成与回归测试。

当前 Git tree 中 `.mbt` 源码约 83.7 KB，而 `.js + .html + .css` 合计约 20.4 KB。该数字只用于说明 MoonBit 是主要源码实现，不作为项目价值评分依据。

## Demo

Playground 第一屏就是工具本体：

~~~text
Collections | Method + URL + Send | Response
            | Body/Headers/Params | status / body / timing
-----------------------------------------------------------
Assertions: ✓ status_is   ✓ json_exists
~~~

内置 Todo API 场景包含 Create / List / Get / Update / Delete，可单独 Send，也可一键按顺序运行。

浏览器版明确遵守 CORS；任意网络访问由 Native CLI 承担。

## 工程验证

当前主路径包括：

- strict `moon check --deny-warn`；
- MoonBit 单元与回归测试；
- Ubuntu / Windows Native build；
- loopback HTTP integration tests；
- JS target check/build；
- 生成 ESM 的 Node 动态导入；
- Bridge 导出函数真实调用；
- Playground JavaScript module 语法检查。

## 开源与合规

- Apache-2.0；
- GitHub 公共仓库与完整开发历史；
- Issues / PR / CHANGELOG 保留开发过程；
- 直接 MoonBit 依赖许可证已审查；
- GitHub Actions 许可证已审查；
- 示例凭据只使用占位符；
- AI 使用与关键架构决策有独立说明。

详见 [THIRD_PARTY.md](THIRD_PARTY.md)、[AI_USAGE.md](AI_USAGE.md) 与 [DEVELOPMENT_RETROSPECTIVE.md](DEVELOPMENT_RETROSPECTIVE.md)。

## 项目边界

v0.1 不实现 OAuth 全流程、gRPC、WebSocket、云同步、账号系统、多人协作、插件市场、完整 Postman Collection 兼容或负载测试。

目标是在九月赛周期内完成一个可运行、可测试、可维护、可解释的 MoonBit API 测试核心与清晰 Demo。
