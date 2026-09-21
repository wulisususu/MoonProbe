///|
struct CollectionFakeTransport {}

///|
#warnings("-implicit_impl_as_method")
impl @core.Transport for CollectionFakeTransport with fn execute(
  _self,
  request,
  _timeout_ms,
) {
  match request.name {
    "create" =>
      Ok(@core.new_response(201, [], "{\"id\":1}", 11))
    "list" =>
      Ok(@core.new_response(200, [], "[{\"id\":1}]", 7))
    "get" =>
      Ok(@core.new_response(200, [], "{\"id\":1}", 5))
    "update" =>
      Ok(@core.new_response(200, [], "{\"id\":1,\"done\":true}", 9))
    "delete" =>
      Ok(@core.new_response(204, [], "", 4))
    "bad-status" =>
      Ok(@core.new_response(500, [], "boom", 3))
    "network" =>
      Err(@core.TransportError("connection refused"))
    _ =>
      Ok(@core.new_response(200, [], "ok", 1))
  }
}

///|
fn todo_collection(stop_on_failure : Bool) -> @core.Collection {
  @core.new_collection(
    "Todo API",
    [
      @core.collection_request(
        @core.new_request("create", @core.POST, "{{base_url}}/todos"),
        [@core.StatusIs(201), @core.JsonEquals("$.id", "1")],
      ),
      @core.collection_request(
        @core.new_request("list", @core.GET, "{{base_url}}/todos"),
        [@core.StatusIs(200), @core.BodyContains("id")],
      ),
      @core.collection_request(
        @core.new_request("get", @core.GET, "{{base_url}}/todos/1"),
        [@core.StatusIs(200), @core.JsonExists("$.id")],
      ),
      @core.collection_request(
        @core.new_request("update", @core.PATCH, "{{base_url}}/todos/1"),
        [@core.StatusIs(200), @core.JsonEquals("$.done", "true")],
      ),
      @core.collection_request(
        @core.new_request("delete", @core.DELETE, "{{base_url}}/todos/1"),
        [@core.StatusIs(204)],
      ),
    ],
    stop_on_failure~,
  )
}

///|
async test "collection runner executes five requests in declaration order" {
  let result = @core.run_collection(
    todo_collection(false),
    @core.environment([
      { name: "base_url", value: "https://api.example.com" },
    ]),
    CollectionFakeTransport::{},
  )

  assert_eq(result.total, 5)
  assert_eq(result.executed, 5)
  assert_eq(result.passed, 5)
  assert_eq(result.failed, 0)
  assert_eq(result.skipped, 0)
  assert_eq(result.duration_ms, 36)
  assert_false(result.stopped_early)
  assert_true(@core.collection_result_passed(result))
  assert_eq(
    result.requests.map(item => item.request_name),
    ["create", "list", "get", "update", "delete"],
  )
}

///|
async test "collection continues after failure by default" {
  let collection = @core.new_collection(
    "continue",
    [
      @core.collection_request(
        @core.new_request("bad-status", @core.GET, "https://example.com/bad"),
        [@core.StatusIs(200)],
      ),
      @core.collection_request(
        @core.new_request("get", @core.GET, "https://example.com/good"),
        [@core.StatusIs(200)],
      ),
    ],
  )
  let result = @core.run_collection(
    collection,
    @core.empty_environment(),
    CollectionFakeTransport::{},
  )

  assert_eq(result.executed, 2)
  assert_eq(result.passed, 1)
  assert_eq(result.failed, 1)
  assert_eq(result.skipped, 0)
  assert_false(result.stopped_early)
  assert_false(@core.collection_result_passed(result))
}

///|
async test "stop-on-failure preserves failure and skips remaining requests" {
  let collection = @core.new_collection(
    "stop",
    [
      @core.collection_request(
        @core.new_request("create", @core.POST, "https://example.com/1"),
        [@core.StatusIs(201)],
      ),
      @core.collection_request(
        @core.new_request("bad-status", @core.GET, "https://example.com/2"),
        [@core.StatusIs(200)],
      ),
      @core.collection_request(
        @core.new_request("delete", @core.DELETE, "https://example.com/3"),
        [@core.StatusIs(204)],
      ),
    ],
    stop_on_failure=true,
  )
  let result = @core.run_collection(
    collection,
    @core.empty_environment(),
    CollectionFakeTransport::{},
  )

  assert_eq(result.total, 3)
  assert_eq(result.executed, 2)
  assert_eq(result.passed, 1)
  assert_eq(result.failed, 1)
  assert_eq(result.skipped, 1)
  assert_eq(result.duration_ms, 14)
  assert_true(result.stopped_early)
  assert_eq(result.requests.length(), 2)
}

///|
async test "transport errors count as failures and can stop a collection" {
  let collection = @core.new_collection(
    "transport failure",
    [
      @core.collection_request(
        @core.new_request("network", @core.GET, "https://example.com"),
        [],
      ),
      @core.collection_request(
        @core.new_request("get", @core.GET, "https://example.com/next"),
        [@core.StatusIs(200)],
      ),
    ],
    stop_on_failure=true,
  )
  let result = @core.run_collection(
    collection,
    @core.empty_environment(),
    CollectionFakeTransport::{},
  )

  assert_eq(result.executed, 1)
  assert_eq(result.failed, 1)
  assert_eq(result.skipped, 1)
  assert_eq(
    result.requests[0].error,
    Some(@core.TransportError("connection refused")),
  )
}

///|
async test "empty collection produces a deterministic empty result" {
  let result = @core.run_collection(
    @core.new_collection("empty", []),
    @core.empty_environment(),
    CollectionFakeTransport::{},
  )
  assert_eq(result.total, 0)
  assert_eq(result.executed, 0)
  assert_eq(result.passed, 0)
  assert_eq(result.failed, 0)
  assert_eq(result.skipped, 0)
  assert_eq(result.duration_ms, 0)
  assert_true(@core.collection_result_passed(result))
}
