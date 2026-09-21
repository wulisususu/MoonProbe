# MoonProbe 开发计划

## 时间窗口

项目启动：**2026-09-21**  
九月赛验收 / 报名截止：**2026-09-30**

开发策略：先 Core，后 CLI，再 Demo；每个阶段都必须留下可运行测试。

## Gate 0 — Repository & Spec

- [x] 创建公开仓库
- [x] README
- [x] 一页项目说明
- [x] Scope / Architecture / API Design
- [x] Test Plan / Demo Plan
- [x] Apache-2.0 License
- [x] 建立 Issues
- [x] 初始化 MoonBit module
- [x] 配置 CI

## Gate 1 — Core Models

- [x] Method
- [x] Header
- [x] Request
- [x] Response
- [x] Environment
- [x] Error Model
- [x] Core 单元测试

验收：无网络即可通过基础模型测试；Linux / Windows CI 已通过。

## Gate 2 — Template & Assertions

- [x] `{{variable}}` 展开
- [x] MissingVariable
- [x] status assertion
- [x] header assertion
- [x] body contains
- [x] JSON field assertion
- [x] duration assertion

验收：Template 与 Assertion Engine 均已完成；Fake Response 可完整执行断言，Linux / Windows CI 已通过。

## Gate 3 — Transport & Single Request

- [x] Transport abstraction
- [x] Native transport
- [x] timeout
- [x] request execution
- [x] integration tests

验收：FakeTransport 可完全替换真实网络；HttpTransport 已在 Linux / Windows CI 中通过本地真实 HTTP 请求与 timeout 集成测试。

## Gate 4 — Collection Runner

- [x] Collection
- [x] ordered runner
- [x] stop-on-failure
- [x] Text Reporter
- [x] JSON Reporter

验收：5 请求 Todo Collection 已通过顺序执行测试；同时覆盖 continue-on-failure、stop-on-failure、assertion failure、transport error、空 Collection，并生成稳定 Text / JSON 报告。

## Gate 5 — CLI

- [x] `moonprobe send`
- [x] `moonprobe run`
- [x] `--env`
- [x] `--format text|json`
- [x] exit codes

验收：CLI 参数解析、JSON 输入解析、Help/Version 执行层均有自动测试；native executable 已在 Linux / Windows 通过 check/test/build。

## Gate 6 — Web Demo

- [ ] Request Builder
- [ ] Response Viewer
- [ ] Collection Sidebar
- [ ] Test Results
- [ ] Built-in Todo API scenario
- [ ] 一键 Run Collection

验收：第一次打开页面的人无需阅读说明即可理解项目用途。

## Gate 7 — Submission

- [ ] README 与真实实现同步
- [ ] 所有示例重新验证
- [ ] CI 全绿
- [ ] Demo 可复现
- [ ] MoonBit 为主要实现语言
- [ ] Issues / commits / PR 记录完整
- [ ] CHANGELOG 更新
- [ ] AI_USAGE 更新
- [ ] 赛事清单全部核对
- [ ] 条件允许时发布至 Mooncakes

## 功能优先级

必须完成：

```text
Core Models
Template
Assertions
Runner
Report
CLI
Simple Demo
Tests
```

时间不足时首先削减：

```text
UI 动画
高级 Auth
导入格式
复杂主题
非必要可视化
```
