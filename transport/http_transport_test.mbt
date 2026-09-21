///|
async test "HTTP transport executes a real local request" {
  @async.with_task_group() <| group => {
    let server = @http.Server(@socket.Addr::parse("127.0.0.1:0"))
    group.add_defer(() => server.close())
    group.spawn_bg(no_wait=true) <| () => {
      server.run_forever() <| ((request, body, conn) => {
        let request_body = body.read_all().text()
        let auth = request.headers
          .get(@http.CaseInsensitiveString("authorization"))
          .unwrap_or("")
        conn
        ..send_response(
          201,
          "Created",
          extra_headers={
            "Content-Type": "application/json",
            "X-Echo-Auth": auth,
          },
        )
        .write(
          "{\"path\":\"\{request.path}\",\"body\":\"\{request_body}\"}",
        )
      })
    }

    let port = server.addr.port()
    let request : @core.Request = {
      name: "local integration",
      http_method: @core.POST,
      url: "http://127.0.0.1:\{port}/todos",
      headers: [],
      query: [{ name: "q", value: "moon bit" }],
      body: @core.Json("{\"title\":\"probe\"}"),
      auth: @core.Bearer("demo-token"),
    }

    match @core.Transport::execute(
      @transport.HttpTransport::new(),
      request,
      2000,
    ) {
      Err(_) => fail("local HTTP request failed")
      Ok(response) => {
        assert_eq(response.status, 201)
        assert_true(response.duration_ms >= 0)
        assert_true(response.body.contains("/todos?q=moon%20bit"))
        assert_true(response.body.contains("probe"))
        let auth_header = response.headers
          .iter()
          .find_first(h => h.name.to_lower() == "x-echo-auth")
        assert_eq(auth_header.map(h => h.value), Some("Bearer demo-token"))
      }
    }
  }
}

///|
async test "HTTP transport maps deadline expiry to Timeout" {
  @async.with_task_group() <| group => {
    let server = @http.Server(@socket.Addr::parse("127.0.0.1:0"))
    group.add_defer(() => server.close())
    group.spawn_bg(no_wait=true) <| () => {
      server.run_forever() <| ((_request, _body, _conn) => {
        @async.sleep(500)
      })
    }

    let port = server.addr.port()
    let request = @core.new_request(
      "timeout integration",
      @core.GET,
      "http://127.0.0.1:\{port}/slow",
    )
    assert_eq(
      @core.Transport::execute(@transport.HttpTransport::new(), request, 30),
      Err(@core.Timeout(30)),
    )
  }
}
