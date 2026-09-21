///|
fn sample_result() -> @core.CollectionResult {
  {
    collection_name: "Todo API",
    total: 3,
    executed: 2,
    passed: 1,
    failed: 1,
    skipped: 1,
    duration_ms: 18,
    stopped_early: true,
    requests: [
      {
        request_name: "create",
        response: Some(@core.new_response(201, [], "{\"id\":1}", 11)),
        assertions: [
          {
            kind: "status_is",
            passed: true,
            expected: "201",
            actual: "201",
            message: "status matched",
          },
        ],
        error: None,
      },
      {
        request_name: "get",
        response: Some(@core.new_response(500, [], "boom", 7)),
        assertions: [
          {
            kind: "status_is",
            passed: false,
            expected: "200",
            actual: "500",
            message: "status did not match",
          },
        ],
        error: None,
      },
    ],
  }
}

///|
test "text report exposes summary, failures, and early stop" {
  let text = @report.collection_report_text(sample_result())
  assert_true(text.contains("MoonProbe Collection: Todo API"))
  assert_true(text.contains("Result: FAIL"))
  assert_true(text.contains("1 passed, 1 failed, 1 skipped"))
  assert_true(text.contains("[PASS] create - HTTP 201 - 11 ms"))
  assert_true(text.contains("[FAIL] get - HTTP 500 - 7 ms"))
  assert_true(text.contains("assertion status_is"))
  assert_true(text.contains("Stopped early after failure"))
}

///|
test "JSON report has a versioned stable top-level shape" {
  let text = @report.collection_report_json(sample_result(), pretty=false)
  let json = @json.parse(text)
  guard json is Object(root) else { fail("report must be an object") }

  assert_eq(
    root.get("schema_version"),
    Some(Json::string("moonprobe.collection-report.v1")),
  )
  assert_eq(root.get("collection"), Some(Json::string("Todo API")))
  assert_eq(root.get("passed"), Some(Json::boolean(false)))

  guard root.get("summary") is Some(Object(summary)) else {
    fail("summary must be an object")
  }
  assert_eq(summary.get("total"), Some(Json::number(3.0)))
  assert_eq(summary.get("executed"), Some(Json::number(2.0)))
  assert_eq(summary.get("skipped"), Some(Json::number(1.0)))
  assert_eq(summary.get("stopped_early"), Some(Json::boolean(true)))

  guard root.get("requests") is Some(Array(requests)) else {
    fail("requests must be an array")
  }
  assert_eq(requests.length(), 2)
}

///|
test "JSON report represents transport failure without a fake response" {
  let result : @core.CollectionResult = {
    collection_name: "network",
    total: 1,
    executed: 1,
    passed: 0,
    failed: 1,
    skipped: 0,
    duration_ms: 0,
    stopped_early: false,
    requests: [
      {
        request_name: "ping",
        response: None,
        assertions: [],
        error: Some(@core.Timeout(250)),
      },
    ],
  }
  let json = @json.parse(@report.collection_report_json(result, pretty=false))
  guard json is Object(root) else { fail("report must be an object") }
  guard root.get("requests") is Some(Array(requests)) else {
    fail("requests must be an array")
  }
  guard requests[0] is Object(request) else { fail("request must be an object") }
  assert_eq(request.get("status"), Some(Json::null()))
  guard request.get("error") is Some(Object(error)) else {
    fail("error must be an object")
  }
  assert_eq(error.get("kind"), Some(Json::string("timeout")))
  assert_eq(
    error.get("message"),
    Some(Json::string("timeout after 250 ms")),
  )
}
