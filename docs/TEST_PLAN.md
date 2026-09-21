# MoonProbe 测试计划

## 测试目标

MoonProbe 的核心价值是“确定性验证 API”，因此项目自身必须有可靠自动化测试。

## 1. Unit Tests

### Request

- method 正确保存
- header 大小写策略
- query encoding
- body 类型
- auth 转换

### Environment / Template

- 单变量替换
- 多变量替换
- 重复变量
- 空值
- 不存在变量
- 非变量文本保持原样

### Assertions

- status pass / fail
- header exists / missing
- header contains
- body contains
- JSON path exists / missing
- JSON equals pass / fail
- duration pass / fail

### Report

- passed / failed 数量
- 失败原因
- JSON schema/version
- 空 Collection

## 2. Fake Transport Tests

不访问真实网络：

```text
Request
 ↓
FakeTransport
 ↓
Response(status=200, body=...)
 ↓
Assertions
 ↓
Result
```

用于测试 Runner 大部分逻辑。

## 3. Integration Tests

少量真实网络测试，只覆盖：

- GET
- POST
- headers
- JSON response
- timeout / network error

网络不稳定的测试不能成为 Core 单元测试的唯一依据。

## 4. Collection Tests

预置 Todo 场景：

1. Create
2. List
3. Get
4. Update
5. Delete

需要覆盖：

- 全通过；
- 中间请求失败但继续；
- stop-on-failure；
- 某个 assertion 失败；
- transport error。

## 5. Regression Fixtures

每发现一个真实 bug，优先增加 fixture：

```text
fixtures/
├─ missing-variable/
├─ invalid-json/
├─ duplicate-header/
├─ timeout/
└─ assertion-failure/
```

## 6. CI 目标

至少执行：

```bash
moon fmt --check
moon check
moon test
moon build
```

具体命令以实际 MoonBit 版本支持为准，CI 文件建立时重新验证。

## 7. Definition of Done

一个功能只有同时满足以下条件才算完成：

- 行为已实现；
- 至少有正例测试；
- 至少有关键失败路径测试；
- README / docs 不与实现矛盾；
- CI 通过。
