# MoonProbe 项目范围

## 项目主体

MoonProbe 的主体是 **MoonBit API 请求与自动化测试核心**。

Web Playground 是用于展示和交互的参考应用，不定义项目边界。

## In Scope

### Core

- Request / Response 数据模型
- HTTP Method
- Header / Query / Body
- Auth Model
- Environment
- Template Expansion
- Assertion
- Collection
- Runner
- Report

### CLI

- 单请求执行
- Collection 执行
- Text / JSON 输出
- exit code 映射

### Demo

- Request Builder
- Response Viewer
- Collection Sidebar
- Assertion Results
- 一键 Demo Collection

## Out of Scope — v0.1

- OAuth 2.0 全流程
- gRPC
- WebSocket
- SSE 调试器
- GraphQL 专用编辑器
- 账号系统
- 云端同步
- 多人协作
- 插件市场
- 完整 Postman Collection 兼容
- 大规模负载测试

## 设计约束

1. MoonBit Core 不依赖 Web UI；
2. Core 的行为必须可自动测试；
3. 同一 Collection 的执行逻辑不能在 CLI 与 Web 各写一份；
4. UI 不应承载关键业务判断；
5. 不为了展示效果牺牲公共 API 的可复用性；
6. MVP 优先保证单机、确定性、可复现。

## 首版完成条件

- 公共 MoonBit API 可以构造 Request；
- 可以运行 Request；
- 可以执行至少 5 类 Assertion；
- 可以运行 Collection；
- 可以生成 Text / JSON Report；
- 有至少一个跨请求示例；
- 有自动化测试；
- CLI 可运行；
- Demo 可展示完整流程。
