///|
fn sample_response() -> @core.Response {
  @core.new_response(
    200,
    [
      {
        name: "Content-Type",
        value: "application/json; charset=utf-8",
      },
      {
        name: "X-Request-Id",
        value: "req-123",
      },
    ],
    "{\"user\":{\"id\":7,\"name\":\"Alice\"},\"ok\":true}",
    42,
  )
}

///|
test "status assertions pass and fail deterministically" {
  let response = sample_response()
  assert_true(
    @core.evaluate_assertion(@core.StatusIs(200), response).passed,
  )
  assert_false(
    @core.evaluate_assertion(@core.StatusIs(201), response).passed,
  )
  assert_true(
    @core
    .evaluate_assertion(@core.StatusBetween(200, 299), response)
    .passed,
  )
  assert_false(
    @core
    .evaluate_assertion(@core.StatusBetween(400, 499), response)
    .passed,
  )
}

///|
test "header lookup is case insensitive" {
  let response = sample_response()
  let exists = @core.evaluate_assertion(
    @core.HeaderExists("content-type"),
    response,
  )
  assert_true(exists.passed)
  assert_eq(exists.actual, "application/json; charset=utf-8")

  assert_true(
    @core
    .evaluate_assertion(
      @core.HeaderContains("CONTENT-TYPE", "application/json"),
      response,
    )
    .passed,
  )
  assert_false(
    @core
    .evaluate_assertion(
      @core.HeaderContains("content-type", "text/html"),
      response,
    )
    .passed,
  )
}

///|
test "body contains assertion reports both outcomes" {
  let response = sample_response()
  assert_true(
    @core
    .evaluate_assertion(@core.BodyContains("Alice"), response)
    .passed,
  )
  assert_false(
    @core
    .evaluate_assertion(@core.BodyContains("Bob"), response)
    .passed,
  )
}

///|
test "JSON path exists supports nested object fields" {
  let response = sample_response()
  assert_true(
    @core
    .evaluate_assertion(@core.JsonExists("$.user.id"), response)
    .passed,
  )
  assert_false(
    @core
    .evaluate_assertion(@core.JsonExists("$.user.email"), response)
    .passed,
  )
}

///|
test "JSON equality compares scalar text" {
  let response = sample_response()
  let name = @core.evaluate_assertion(
    @core.JsonEquals("$.user.name", "Alice"),
    response,
  )
  assert_true(name.passed)
  assert_eq(name.actual, "Alice")

  let id = @core.evaluate_assertion(
    @core.JsonEquals("$.user.id", "7"),
    response,
  )
  assert_true(id.passed)

  assert_false(
    @core
    .evaluate_assertion(
      @core.JsonEquals("$.user.name", "Bob"),
      response,
    )
    .passed,
  )
}

///|
test "JSON assertions fail cleanly for invalid JSON" {
  let response = @core.new_response(
    200,
    [],
    "not-json",
    12,
  )
  let result = @core.evaluate_assertion(
    @core.JsonExists("$.id"),
    response,
  )
  assert_false(result.passed)
  assert_eq(result.actual, "<invalid-json>")
}

///|
test "unsupported JSON paths are reported as missing" {
  let response = sample_response()
  let result = @core.evaluate_assertion(
    @core.JsonExists("user.id"),
    response,
  )
  assert_false(result.passed)
  assert_eq(result.actual, "<missing>")
}

///|
test "response time uses strict less-than semantics" {
  let response = sample_response()
  assert_true(
    @core
    .evaluate_assertion(@core.ResponseTimeLessThan(50), response)
    .passed,
  )
  assert_false(
    @core
    .evaluate_assertion(@core.ResponseTimeLessThan(42), response)
    .passed,
  )
}

///|
test "assertion collections preserve order and aggregate pass state" {
  let response = sample_response()
  let passing = @core.evaluate_assertions(
    [
      @core.StatusIs(200),
      @core.JsonExists("$.user.id"),
      @core.ResponseTimeLessThan(100),
    ],
    response,
  )
  assert_eq(passing.length(), 3)
  assert_true(@core.assertions_passed(passing))

  let mixed = @core.evaluate_assertions(
    [
      @core.StatusIs(200),
      @core.JsonEquals("$.user.name", "Bob"),
    ],
    response,
  )
  assert_false(@core.assertions_passed(mixed))
}
