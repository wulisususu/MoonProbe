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
- [ ] status assertion
- [ ] header assertion
- [ ] body contains
- [ ] JSON field assertion
- [ ] duration assertion

进度：Template 部分已完成并通过 Linux / Windows CI；Assertion Engine 待实现。

验收：Fake Response 可以完整跑断言。

## Gate 3 — Transport & Single Request

- [ ] Transport abstraction
- [ ] Native transport
- [ ] timeout
- [ ] request execution
- [ ] integration tests

验收：CLI 或示例可真实访问测试 API。

## Gate 4 — Collection Runner

- [ ] Collection
- [ ] ordered runner
- [ ] stop-on-failure
- [ ] Text Reporter
- [ ] JSON Reporter

验收：一个 5 请求 Collection 可以稳定得到报告。

## Gate 5 — CLI

- [ ] `moonprobe send`
- [ ] `moonprobe run`
- [ ] `--env`
- [ ] `--format text|json`
- [ ] exit codes

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
