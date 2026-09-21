///|
test "request document applies useful defaults" {
  let text =
    #|{"name":"health","method":"GET","url":"{{base_url}}/health","assertions":[{"type":"status_is","expected":200}]}
  match parse_request_document(text, "request.json") {
    Err(message) => fail(message)
    Ok(item) => {
      assert_eq(item.request.name, "health")
      assert_eq(item.request.http_method, @core.GET)
      assert_eq(item.request.body, @core.Empty)
      assert_eq(item.request.auth, @core.NoAuth)
      assert_eq(item.request.headers.length(), 0)
      assert_eq(item.request.query.length(), 0)
      assert_eq(item.timeout_ms, 10000)
      assert_eq(item.assertions, [@core.StatusIs(200)])
    }
  }
}

///|
test "request document parses headers query JSON body and auth" {
  let text =
    #|{"name":"create","method":"POST","url":"{{base_url}}/todos","headers":[{"name":"x-client","value":"moonprobe"}],"query":[{"name":"draft","value":"false"}],"body":{"title":"MoonProbe"},"auth":{"type":"bearer","token":"{{token}}"},"timeout_ms":1500,"assertions":[{"type":"json_equals","path":"$.title","expected":"MoonProbe"},{"type":"response_time_less_than","ms":500}]}
  match parse_request_document(text, "request.json") {
    Err(message) => fail(message)
    Ok(item) => {
      assert_eq(item.request.http_method, @core.POST)
      assert_eq(
        item.request.headers,
        [{ name: "x-client", value: "moonprobe" }],
      )
      assert_eq(item.request.query, [{ name: "draft", value: "false" }])
      assert_eq(item.request.body, @core.Json("{\"title\":\"MoonProbe\"}"))
      assert_eq(item.request.auth, @core.Bearer("{{token}}"))
      assert_eq(item.timeout_ms, 1500)
      assert_eq(item.assertions.length(), 2)
    }
  }
}

///|
test "collection and environment documents parse independently" {
  let collection_text =
    #|{"name":"Todo API","stop_on_failure":true,"requests":[{"name":"list","method":"GET","url":"{{base_url}}/todos"}]}
  match parse_collection_document(collection_text, "collection.json") {
    Err(message) => fail(message)
    Ok(collection) => {
      assert_eq(collection.name, "Todo API")
      assert_true(collection.stop_on_failure)
      assert_eq(collection.requests.length(), 1)
    }
  }

  match parse_environment_document(
    "{\"base_url\":\"https://api.example.com\",\"token\":\"demo\"}",
    "env.json",
  ) {
    Err(message) => fail(message)
    Ok(env) => {
      assert_eq(@core.environment_get(env, "base_url"), Some("https://api.example.com"))
      assert_eq(@core.environment_get(env, "token"), Some("demo"))
    }
  }
}

///|
test "input parser rejects unsupported method and malformed assertions" {
  assert_eq(
    parse_request_document(
      "{\"name\":\"x\",\"method\":\"TRACE\",\"url\":\"https://example.com\"}",
      "request.json",
    ),
    Err("unsupported HTTP method: TRACE"),
  )
  assert_eq(
    parse_request_document(
      "{\"name\":\"x\",\"method\":\"GET\",\"url\":\"https://example.com\",\"assertions\":[{\"type\":\"unknown\"}]}",
      "request.json",
    ),
    Err("assertions: unsupported assertion type: unknown"),
  )
}
