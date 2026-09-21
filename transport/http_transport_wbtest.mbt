///|
test "query builder percent encodes names and values and preserves fragments" {
  let request : @core.Request = {
    name: "query",
    http_method: @core.GET,
    url: "https://example.com/path?existing=1#frag",
    headers: [],
    query: [
      { name: "search term", value: "a+b/中文" },
    ],
    body: @core.Empty,
    auth: @core.NoAuth,
  }
  let expected =
    "https://example.com/path?existing=1&search%20term=a%2Bb%2F%E4%B8%AD%E6%96%87#frag"
  assert_eq(append_query(request.url, request.query), expected)
}

///|
test "basic auth is UTF8 then base64" {
  assert_eq(
    auth_value(@core.Basic("demo", "secret")),
    Some("Basic ZGVtbzpzZWNyZXQ="),
  )
}
