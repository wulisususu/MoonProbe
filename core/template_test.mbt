///|
test "template expands one variable" {
  let env = @core.environment([
    { name: "base_url", value: "https://api.example.com" },
  ])
  assert_eq(
    @core.render_template("{{base_url}}/users", env),
    Ok("https://api.example.com/users"),
  )
}

///|
test "template expands repeated and multiple variables" {
  let env = @core.environment([
    { name: "host", value: "api.example.com" },
    { name: "id", value: "42" },
  ])
  assert_eq(
    @core.render_template(
      "https://{{host}}/users/{{id}}?owner={{id}}",
      env,
    ),
    Ok("https://api.example.com/users/42?owner=42"),
  )
}

///|
test "template keeps inserted values literal in a single pass" {
  let env = @core.environment([
    { name: "value", value: "{{not_recursive}}" },
    { name: "not_recursive", value: "expanded" },
  ])
  assert_eq(
    @core.render_template("prefix-{{value}}-suffix", env),
    Ok("prefix-{{not_recursive}}-suffix"),
  )
}

///|
test "template supports unicode environment values" {
  let env = @core.environment([
    { name: "city", value: "无锡" },
  ])
  assert_eq(
    @core.render_template("/weather/{{city}}", env),
    Ok("/weather/无锡"),
  )
}

///|
test "template reports the exact missing variable" {
  let env = @core.empty_environment()
  assert_eq(
    @core.render_template("Bearer {{token}}", env),
    Err(@core.MissingVariable("token")),
  )
}

///|
test "template rejects unclosed placeholders" {
  let env = @core.empty_environment()
  assert_eq(
    @core.render_template("https://example.com/{{id", env),
    Err(@core.InvalidRequest("unclosed template variable")),
  )
}

///|
test "template rejects empty placeholders" {
  let env = @core.empty_environment()
  assert_eq(
    @core.render_template("value={{}}", env),
    Err(
      @core.InvalidRequest(
        "template variable name must not be empty",
      ),
    ),
  )
}

///|
test "render request expands url headers query body and auth" {
  let request : @core.Request = {
    name: "Create todo",
    http_method: @core.POST,
    url: "{{base_url}}/todos/{{id}}",
    headers: [
      {
        name: "X-{{header_name}}",
        value: "{{header_value}}",
      },
    ],
    query: [
      {
        name: "{{query_name}}",
        value: "{{query_value}}",
      },
    ],
    body: @core.Json(
      "{\"title\":\"{{title}}\",\"id\":\"{{id}}\"}",
    ),
    auth: @core.Bearer("{{token}}"),
  }
  let env = @core.environment([
    { name: "base_url", value: "https://api.example.com" },
    { name: "id", value: "7" },
    { name: "header_name", value: "Trace" },
    { name: "header_value", value: "abc" },
    { name: "query_name", value: "include" },
    { name: "query_value", value: "details" },
    { name: "title", value: "MoonProbe" },
    { name: "token", value: "secret" },
  ])

  match @core.render_request(request, env) {
    Err(_) => fail("unexpected render error")
    Ok(rendered) => {
      assert_eq(rendered.url, "https://api.example.com/todos/7")
      assert_eq(rendered.headers[0].name, "X-Trace")
      assert_eq(rendered.headers[0].value, "abc")
      assert_eq(rendered.query[0].name, "include")
      assert_eq(rendered.query[0].value, "details")
      assert_eq(
        rendered.body,
        @core.Json("{\"title\":\"MoonProbe\",\"id\":\"7\"}"),
      )
      assert_eq(rendered.auth, @core.Bearer("secret"))

      // Source request remains unchanged.
      assert_eq(request.url, "{{base_url}}/todos/{{id}}")
      assert_eq(request.auth, @core.Bearer("{{token}}"))
    }
  }
}

///|
test "render request stops on missing field variable" {
  let request : @core.Request = {
    name: "Missing token",
    http_method: @core.GET,
    url: "https://api.example.com",
    headers: [
      {
        name: "Authorization",
        value: "Bearer {{token}}",
      },
    ],
    query: [],
    body: @core.Empty,
    auth: @core.NoAuth,
  }

  assert_eq(
    @core.render_request(request, @core.empty_environment()),
    Err(@core.MissingVariable("token")),
  )
}
