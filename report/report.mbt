///|
/// Stable schema identifier for machine-readable Collection reports.
pub const COLLECTION_REPORT_SCHEMA : String = "moonprobe.collection-report.v1"

///|
fn error_message(error : @core.ProbeError) -> String {
  match error {
    InvalidRequest(message) => "invalid request: \{message}"
    InvalidUrl(value) => "invalid URL: \{value}"
    InvalidHeader(message) => "invalid header: \{message}"
    MissingVariable(name) => "missing variable: \{name}"
    TransportError(message) => "transport error: \{message}"
    Timeout(ms) => "timeout after \{ms} ms"
    InvalidResponse(message) => "invalid response: \{message}"
    AssertionFailure(message) => "assertion failure: \{message}"
    CollectionError(message) => "collection error: \{message}"
  }
}

///|
fn error_kind(error : @core.ProbeError) -> String {
  match error {
    InvalidRequest(_) => "invalid_request"
    InvalidUrl(_) => "invalid_url"
    InvalidHeader(_) => "invalid_header"
    MissingVariable(_) => "missing_variable"
    TransportError(_) => "transport_error"
    Timeout(_) => "timeout"
    InvalidResponse(_) => "invalid_response"
    AssertionFailure(_) => "assertion_failure"
    CollectionError(_) => "collection_error"
  }
}

///|
fn assertion_json(result : @core.AssertionResult) -> Json {
  Json::object({
    "kind": Json::string(result.kind),
    "passed": Json::boolean(result.passed),
    "expected": Json::string(result.expected),
    "actual": Json::string(result.actual),
    "message": Json::string(result.message),
  })
}

///|
fn request_json(result : @core.RequestResult) -> Json {
  let assertions : Array[Json] = []
  for assertion in result.assertions {
    assertions.push(assertion_json(assertion))
  }

  let status = match result.response {
    Some(response) => Json::number(response.status.to_double())
    None => Json::null()
  }
  let duration_ms = match result.response {
    Some(response) => Json::number(response.duration_ms.to_double())
    None => Json::null()
  }
  let error = match result.error {
    Some(value) =>
      Json::object({
        "kind": Json::string(error_kind(value)),
        "message": Json::string(error_message(value)),
      })
    None => Json::null()
  }

  Json::object({
    "name": Json::string(result.request_name),
    "passed": Json::boolean(@core.request_result_passed(result)),
    "status": status,
    "duration_ms": duration_ms,
    "error": error,
    "assertions": Json::array(assertions),
  })
}

///|
/// Render a stable machine-readable Collection report.
pub fn collection_report_json(
  result : @core.CollectionResult,
  pretty? : Bool = true,
) -> String {
  let requests : Array[Json] = []
  for request in result.requests {
    requests.push(request_json(request))
  }

  let json = Json::object({
    "schema_version": Json::string(COLLECTION_REPORT_SCHEMA),
    "collection": Json::string(result.collection_name),
    "passed": Json::boolean(@core.collection_result_passed(result)),
    "summary": Json::object({
      "total": Json::number(result.total.to_double()),
      "executed": Json::number(result.executed.to_double()),
      "passed": Json::number(result.passed.to_double()),
      "failed": Json::number(result.failed.to_double()),
      "skipped": Json::number(result.skipped.to_double()),
      "duration_ms": Json::number(result.duration_ms.to_double()),
      "stopped_early": Json::boolean(result.stopped_early),
    }),
    "requests": Json::array(requests),
  })

  if pretty {
    json.stringify(indent=2)
  } else {
    json.stringify()
  }
}

///|
/// Render a compact human-readable Collection report.
pub fn collection_report_text(result : @core.CollectionResult) -> String {
  let out = StringBuilder()
  out.write_string("MoonProbe Collection: \{result.collection_name}\n")
  out.write_string(
    "Result: \{if @core.collection_result_passed(result) { "PASS" } else { "FAIL" }}\n",
  )
  out.write_string(
    "Summary: \{result.passed} passed, \{result.failed} failed, " +
    "\{result.skipped} skipped, \{result.executed}/\{result.total} executed, " +
    "\{result.duration_ms} ms\n",
  )

  for request in result.requests {
    let state = if @core.request_result_passed(request) { "PASS" } else { "FAIL" }
    match request.response {
      Some(response) =>
        out.write_string(
          "[\{state}] \{request.request_name} - HTTP \{response.status} - " +
          "\{response.duration_ms} ms\n",
        )
      None =>
        out.write_string("[\{state}] \{request.request_name}\n")
    }

    match request.error {
      Some(error) =>
        out.write_string("  error: \{error_message(error)}\n")
      None => ()
    }

    for assertion in request.assertions {
      if !assertion.passed {
        out.write_string(
          "  assertion \{assertion.kind}: \{assertion.message} " +
          "(expected \{assertion.expected}, actual \{assertion.actual})\n",
        )
      }
    }
  }

  if result.stopped_early {
    out.write_string(
      "Stopped early after failure; \{result.skipped} request(s) skipped.\n",
    )
  }
  out.to_string()
}
