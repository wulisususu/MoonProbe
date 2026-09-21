///|
test "method tokens are canonical" {
  assert_eq(@core.method_to_string(@core.GET), "GET")
  assert_eq(@core.method_to_string(@core.POST), "POST")
  assert_eq(@core.method_to_string(@core.PUT), "PUT")
  assert_eq(@core.method_to_string(@core.PATCH), "PATCH")
  assert_eq(@core.method_to_string(@core.DELETE), "DELETE")
}

///|
test "new request has deterministic empty defaults" {
  let req = @core.new_request(
    "Get user",
    @core.GET,
    "https://api.example.com/users/1",
  )
  assert_eq(req.name, "Get user")
  assert_eq(req.http_method, @core.GET)
  assert_eq(req.url, "https://api.example.com/users/1")
  assert_eq(req.headers.length(), 0)
  assert_eq(req.query.length(), 0)
  assert_eq(req.body, @core.Empty)
  assert_eq(req.auth, @core.NoAuth)
}

///|
test "response model preserves transport result" {
  let headers : Array[@core.Header] = [
    { name: "content-type", value: "application/json" },
  ]
  let response = @core.new_response(
    200,
    headers,
    "{\"id\":1}",
    42,
  )
  assert_eq(response.status, 200)
  assert_eq(response.headers.length(), 1)
  assert_eq(response.headers[0].name, "content-type")
  assert_eq(response.body, "{\"id\":1}")
  assert_eq(response.duration_ms, 42)
}

///|
test "environment returns explicit variables" {
  let env = @core.environment([
    { name: "base_url", value: "https://api.example.com" },
    { name: "token", value: "demo-token" },
  ])
  assert_eq(
    @core.environment_get(env, "base_url"),
    Some("https://api.example.com"),
  )
  assert_eq(@core.environment_get(env, "token"), Some("demo-token"))
  assert_eq(@core.environment_get(env, "missing"), None)
}

///|
test "environment set appends and replaces without mutating input" {
  let original = @core.environment([
    { name: "base_url", value: "https://old.example.com" },
  ])
  let with_token = @core.environment_set(original, "token", "abc")
  let replaced = @core.environment_set(
    with_token,
    "base_url",
    "https://new.example.com",
  )

  assert_eq(@core.environment_get(original, "token"), None)
  assert_eq(@core.environment_get(with_token, "token"), Some("abc"))
  assert_eq(
    @core.environment_get(replaced, "base_url"),
    Some("https://new.example.com"),
  )
  assert_eq(replaced.values.length(), 2)
}

///|
test "structured errors retain their payload" {
  let err : @core.ProbeError = @core.MissingVariable("token")
  assert_eq(err, @core.MissingVariable("token"))
}
