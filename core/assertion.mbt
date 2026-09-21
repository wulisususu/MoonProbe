///|
/// Assertions supported by the MoonProbe MVP.
pub(all) enum Assertion {
  StatusIs(Int)
  StatusBetween(Int, Int)
  HeaderExists(String)
  HeaderContains(String, String)
  BodyContains(String)
  JsonExists(String)
  JsonEquals(String, String)
  ResponseTimeLessThan(Int)
} derive(Eq, @debug.Debug)

pub extend Assertion with Eq::{not_equal, equal}
pub extend Assertion with @debug.Debug::{to_repr}

///|
/// Stable result returned for every evaluated assertion.
pub(all) struct AssertionResult {
  kind : String
  passed : Bool
  expected : String
  actual : String
  message : String
} derive(Eq, @debug.Debug)

pub extend AssertionResult with Eq::{not_equal, equal}
pub extend AssertionResult with @debug.Debug::{to_repr}

///|
fn assertion_result(
  kind : String,
  passed : Bool,
  expected : String,
  actual : String,
  message : String,
) -> AssertionResult {
  { kind, passed, expected, actual, message }
}

///|
fn find_header(response : Response, name : String) -> String? {
  let wanted = name.to_lower()
  for header in response.headers {
    if header.name.to_lower() == wanted {
      return Some(header.value)
    }
  }
  None
}

///|
/// Minimal JSON path lookup for the MVP.
///
/// Supported forms:
/// - $
/// - $.id
/// - $.user.id
///
/// Array indexes and quoted keys are intentionally out of scope for v0.1.
fn json_path_get(root : Json, path : String) -> Json? {
  if path == "$" {
    return Some(root)
  }
  if !path.has_prefix("$.") || path.length() <= 2 {
    return None
  }

  let mut current = root
  let tail = path[2:]
  for segment in tail.split(".") {
    let key = segment.to_owned()
    if key.length() == 0 {
      return None
    }
    match current {
      Object(obj) =>
        match obj.get(key) {
          Some(value) => current = value
          None => return None
        }
      _ => return None
    }
  }
  Some(current)
}

///|
fn parse_json_body(body : String) -> Json? {
  try {
    Some(@json.parse(body))
  } catch {
    (_ : @json.ParseError) => None
  }
}

///|
fn json_value_text(value : Json) -> String {
  match value {
    String(text) => text
    _ => value.stringify()
  }
}

///|
/// Evaluate one assertion against a response.
pub fn evaluate_assertion(
  assertion : Assertion,
  response : Response,
) -> AssertionResult {
  match assertion {
    StatusIs(expected) => {
      let actual = response.status
      assertion_result(
        "status_is",
        actual == expected,
        "\{expected}",
        "\{actual}",
        if actual == expected {
          "status matched"
        } else {
          "status did not match"
        },
      )
    }
    StatusBetween(min, max) => {
      let actual = response.status
      let passed = actual >= min && actual <= max
      assertion_result(
        "status_between",
        passed,
        "\{min}..\{max}",
        "\{actual}",
        if passed {
          "status is inside the expected range"
        } else {
          "status is outside the expected range"
        },
      )
    }
    HeaderExists(name) =>
      match find_header(response, name) {
        Some(value) =>
          assertion_result(
            "header_exists",
            true,
            name,
            value,
            "header exists",
          )
        None =>
          assertion_result(
            "header_exists",
            false,
            name,
            "<missing>",
            "header is missing",
          )
      }
    HeaderContains(name, fragment) =>
      match find_header(response, name) {
        Some(value) => {
          let passed = value.contains(fragment)
          assertion_result(
            "header_contains",
            passed,
            fragment,
            value,
            if passed {
              "header contains expected text"
            } else {
              "header does not contain expected text"
            },
          )
        }
        None =>
          assertion_result(
            "header_contains",
            false,
            fragment,
            "<missing>",
            "header is missing",
          )
      }
    BodyContains(fragment) => {
      let passed = response.body.contains(fragment)
      assertion_result(
        "body_contains",
        passed,
        fragment,
        response.body,
        if passed {
          "body contains expected text"
        } else {
          "body does not contain expected text"
        },
      )
    }
    JsonExists(path) =>
      match parse_json_body(response.body) {
        None =>
          assertion_result(
            "json_exists",
            false,
            path,
            "<invalid-json>",
            "response body is not valid JSON",
          )
        Some(root) =>
          match json_path_get(root, path) {
            Some(value) =>
              assertion_result(
                "json_exists",
                true,
                path,
                json_value_text(value),
                "JSON path exists",
              )
            None =>
              assertion_result(
                "json_exists",
                false,
                path,
                "<missing>",
                "JSON path does not exist",
              )
          }
      }
    JsonEquals(path, expected) =>
      match parse_json_body(response.body) {
        None =>
          assertion_result(
            "json_equals",
            false,
            expected,
            "<invalid-json>",
            "response body is not valid JSON",
          )
        Some(root) =>
          match json_path_get(root, path) {
            None =>
              assertion_result(
                "json_equals",
                false,
                expected,
                "<missing>",
                "JSON path does not exist",
              )
            Some(value) => {
              let actual = json_value_text(value)
              let passed = actual == expected
              assertion_result(
                "json_equals",
                passed,
                expected,
                actual,
                if passed {
                  "JSON value matched"
                } else {
                  "JSON value did not match"
                },
              )
            }
          }
      }
    ResponseTimeLessThan(limit_ms) => {
      let actual = response.duration_ms
      let passed = actual < limit_ms
      assertion_result(
        "response_time_less_than",
        passed,
        "< \{limit_ms} ms",
        "\{actual} ms",
        if passed {
          "response time is below the limit"
        } else {
          "response time exceeded the limit"
        },
      )
    }
  }
}

///|
/// Evaluate assertions in declaration order.
pub fn evaluate_assertions(
  assertions : Array[Assertion],
  response : Response,
) -> Array[AssertionResult] {
  let results : Array[AssertionResult] = []
  for assertion in assertions {
    results.push(evaluate_assertion(assertion, response))
  }
  results
}

///|
/// Return true only when every assertion passed.
pub fn assertions_passed(results : Array[AssertionResult]) -> Bool {
  for result in results {
    if !result.passed {
      return false
    }
  }
  true
}
