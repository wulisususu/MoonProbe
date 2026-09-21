///|
struct FakeTransport {
  result : Result[@core.Response, @core.ProbeError]
}

///|
impl @core.Transport for FakeTransport with fn execute(
  self,
  _request,
  _timeout_ms,
) {
  self.result
}

///|
async test "runner expands templates before transport and evaluates checks" {
  let request : @core.Request = {
    name: "Get user",
    http_method: @core.GET,
    url: "{{base_url}}/users/7",
    headers: [],
    query: [],
    body: @core.Empty,
    auth: @core.NoAuth,
  }
  let response = @core.new_response(
    200,
    [{ name: "content-type", value: "application/json" }],
    "{\"id\":7}",
    12,
  )
  let result = @core.run_request(
    request,
    @core.environment([
      { name: "base_url", value: "https://api.example.com" },
    ]),
    [
      @core.StatusIs(200),
      @core.JsonEquals("$.id", "7"),
    ],
    FakeTransport::{ result: Ok(response) },
  )

  assert_eq(result.request_name, "Get user")
  assert_eq(result.error, None)
  assert_eq(result.response, Some(response))
  assert_eq(result.assertions.length(), 2)
  assert_true(@core.request_result_passed(result))
}

///|
async test "runner stops before transport when template rendering fails" {
  let request = @core.new_request(
    "Missing variable",
    @core.GET,
    "{{base_url}}/users",
  )
  let response = @core.new_response(200, [], "ok", 1)
  let result = @core.run_request(
    request,
    @core.empty_environment(),
    [],
    FakeTransport::{ result: Ok(response) },
  )

  assert_eq(result.error, Some(@core.MissingVariable("base_url")))
  assert_eq(result.response, None)
  assert_eq(result.assertions.length(), 0)
  assert_false(@core.request_result_passed(result))
}

///|
async test "runner preserves structured transport failures" {
  let request = @core.new_request(
    "Timeout",
    @core.GET,
    "https://api.example.com",
  )
  let result = @core.run_request(
    request,
    @core.empty_environment(),
    [@core.StatusIs(200)],
    FakeTransport::{
      result: Err(@core.Timeout(250)),
    },
    timeout_ms=250,
  )

  assert_eq(result.error, Some(@core.Timeout(250)))
  assert_eq(result.response, None)
  assert_eq(result.assertions.length(), 0)
  assert_false(@core.request_result_passed(result))
}

///|
async test "runner validates timeout before execution" {
  let request = @core.new_request(
    "Bad timeout",
    @core.GET,
    "https://api.example.com",
  )
  let result = @core.run_request(
    request,
    @core.empty_environment(),
    [],
    FakeTransport::{
      result: Err(@core.TransportError("must not be reached")),
    },
    timeout_ms=0,
  )

  assert_eq(
    result.error,
    Some(@core.InvalidRequest("timeout_ms must be greater than zero")),
  )
}
