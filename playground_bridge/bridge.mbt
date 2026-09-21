///|
fn bridge_error(message : String) -> String {
  Json::object({
    "ok": Json::boolean(false),
    "error": Json::string(message),
  }).stringify()
}

///|
fn header_json(header : @core.Header) -> Json {
  Json::object({
    "name": Json::string(header.name),
    "value": Json::string(header.value),
  })
}

///|
fn prepared_request_json(
  item : @core.CollectionRequest,
  rendered : @core.Request,
) -> String {
  let headers : Array[Json] = []
  for header in rendered.headers {
    headers.push(header_json(header))
  }

  let query : Array[Json] = []
  for param in rendered.query {
    query.push(
      Json::object({
        "name": Json::string(param.name),
        "value": Json::string(param.value),
      }),
    )
  }

  let body = match rendered.body {
    @core.Empty =>
      Json::object({
        "kind": Json::string("empty"),
        "value": Json::string(""),
      })
    @core.Text(value) =>
      Json::object({
        "kind": Json::string("text"),
        "value": Json::string(value),
      })
    @core.Json(value) =>
      Json::object({
        "kind": Json::string("json"),
        "value": Json::string(value),
      })
  }

  let auth = match rendered.auth {
    @core.NoAuth =>
      Json::object({ "type": Json::string("none") })
    @core.Bearer(token) =>
      Json::object({
        "type": Json::string("bearer"),
        "token": Json::string(token),
      })
    @core.Basic(username, password) =>
      Json::object({
        "type": Json::string("basic"),
        "username": Json::string(username),
        "password": Json::string(password),
      })
  }

  Json::object({
    "ok": Json::boolean(true),
    "request": Json::object({
      "name": Json::string(rendered.name),
      "method": Json::string(@core.method_to_string(rendered.http_method)),
      "url": Json::string(rendered.url),
      "headers": Json::array(headers),
      "query": Json::array(query),
      "body": body,
      "auth": auth,
      "timeout_ms": Json::number(item.timeout_ms.to_double()),
    }),
  }).stringify()
}

///|
/// Parse the same Request/Environment JSON used by the CLI, then apply the
/// MoonBit Core template engine before browser fetch performs network IO.
#export_name("prepare_request_json")
pub fn prepare_request_json(request_text : String, env_text : String) -> String {
  let item = match @wire.parse_request_document(request_text, "playground request") {
    Ok(value) => value
    Err(message) => return bridge_error(message)
  }
  let env = match @wire.parse_environment_document(env_text, "playground environment") {
    Ok(value) => value
    Err(message) => return bridge_error(message)
  }

  match @core.render_request(item.request, env) {
    Ok(rendered) => prepared_request_json(item, rendered)
    Err(error) => bridge_error(@debug.to_string(error))
  }
}

///|
fn response_from_json(text : String) -> Result[@core.Response, String] {
  let root = try {
    @json.parse(text)
  } catch {
    (_ : @json.ParseError) => return Err("invalid browser response JSON")
  }

  guard root is Object(object) else {
    return Err("browser response must be an object")
  }

  let status = match object.get("status") {
    Some(Number(value, ..)) => value.to_int()
    _ => return Err("browser response status must be a number")
  }
  let body = match object.get("body") {
    Some(String(value)) => value
    _ => return Err("browser response body must be a string")
  }
  let duration_ms = match object.get("duration_ms") {
    Some(Number(value, ..)) => value.to_int()
    _ => return Err("browser response duration_ms must be a number")
  }

  let headers : Array[@core.Header] = []
  match object.get("headers") {
    None | Some(Null) => ()
    Some(Array(values)) =>
      for value in values {
        guard value is Object(fields) else {
          return Err("browser response headers must contain objects")
        }
        let name = match fields.get("name") {
          Some(String(value)) => value
          _ => return Err("browser response header name must be a string")
        }
        let header_value = match fields.get("value") {
          Some(String(value)) => value
          _ => return Err("browser response header value must be a string")
        }
        headers.push({ name, value: header_value })
      }
    Some(_) => return Err("browser response headers must be an array")
  }

  Ok(@core.new_response(status, headers, body, duration_ms))
}

///|
/// Evaluate browser-fetched response data with MoonBit Core assertions and
/// return the same versioned JSON report shape used by the native CLI.
#export_name("evaluate_response_report_json")
pub fn evaluate_response_report_json(
  request_text : String,
  response_text : String,
) -> String {
  let item = match @wire.parse_request_document(request_text, "playground request") {
    Ok(value) => value
    Err(message) => return bridge_error(message)
  }
  let response = match response_from_json(response_text) {
    Ok(value) => value
    Err(message) => return bridge_error(message)
  }

  let assertions = @core.evaluate_assertions(item.assertions, response)
  let request_result : @core.RequestResult = {
    request_name: item.request.name,
    response: Some(response),
    assertions,
    error: None,
  }
  let passed = @core.request_result_passed(request_result)
  let collection_result : @core.CollectionResult = {
    collection_name: "Playground: \{item.request.name}",
    total: 1,
    executed: 1,
    passed: if passed { 1 } else { 0 },
    failed: if passed { 0 } else { 1 },
    skipped: 0,
    duration_ms: response.duration_ms,
    stopped_early: false,
    requests: [request_result],
  }

  @report.collection_report_json(collection_result, pretty=false)
}
