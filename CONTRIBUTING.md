# Contributing to MoonProbe

感谢参与 MoonProbe。

## 开发原则

- Core first；
- MoonBit 为主要实现语言；
- 新功能必须有测试；
- 避免把核心逻辑写进 Web UI；
- 优先小而清晰的 commit；
- Bug 修复尽量附 regression test。

## 工作流

1. 创建或选择 Issue；
2. 建立功能分支；
3. 编写实现与测试；
4. 运行格式化、检查、测试；
5. 更新相关文档；
6. 提交 PR。

建议分支命名：

```text
feat/assertion-engine
feat/collection-runner
fix/template-missing-variable
docs/demo-guide
```

## Commit 风格

建议 Conventional Commits：

```text
feat(core): add request model
test(assertion): cover status mismatch
fix(template): report missing variables
docs: update competition checklist
```

## Core 变更要求

修改公共 API 时，请同时考虑：

- 是否能被 CLI 与 Web 同时使用；
- 是否引入不必要的平台依赖；
- 错误是否结构化；
- 是否破坏已有 examples；
- 是否需要更新 API_DESIGN.md。

## 测试

目标命令：

```bash
moon fmt
moon check
moon test
moon build
```

以仓库实际 MoonBit 工具链支持为准。

## 安全

不要提交：

- API key
- access token
- cookie
- 私有 URL 凭据
- 用户真实敏感数据

Demo 与 fixtures 使用虚构数据。
