///|
/// Default HTTP transport backed by moonbitlang/async.
///
/// The type contains no mutable connection state: each execute call owns its
/// request lifecycle, which keeps behavior deterministic for the MVP.
pub(all) enum HttpTransport {
  DefaultHttpTransport
}

///|
/// Construct the default HTTP transport.
pub fn HttpTransport::new() -> HttpTransport {
  DefaultHttpTransport
}

///|
fn request_method(http_method : @core.Method) -> @http.RequestMethod {
  match http_method {
    GET => @http.Get
    POST => @http.Post
    PUT => @http.Put
    PATCH => @http.Patch
    DELETE => @http.Delete
    HEAD => @http.Head
    OPTIONS => @http.Options
  }
}

///|
fn append_query(
  url : String,
  query : Array[@core.QueryParam],
) -> String {
  if query.length() == 0 {
    return url
  }

  let (base, fragment) = match url.find("#") {
    None => (url, "")
    Some(index) => (
      url[:index].to_owned(),
      url[index:].to_owned(),
    )
  }

  let builder = StringBuilder()
  builder.write_string(base)
  if base.contains("?") {
    if !base.has_suffix("?") && !base.has_suffix("&") {
      builder.write_char('&')
    }
  } else {
    builder.write_char('?')
  }

  for index, param in query {
    if index > 0 {
      builder.write_char('&')
    }
    builder.write_string(@percent.encode(param.name))
    builder.write_char('=')
    builder.write_string(@percent.encode(param.value))
  }
  builder.write_string(fragment)
  builder.to_string()
}

///|
fn auth_value(auth : @core.Auth) -> String? {
  match auth {
    NoAuth => None
    Bearer(token) => Some("Bearer \{token}")
    Basic(username, password) => {
      let raw = "\{username}:\{password}"
      let encoded = @base64.encode(@utf8.encode(raw))
      Some("Basic \{encoded}")
    }
  }
}

///|
fn build_headers(request : @core.Request) -> @http.Headers {
  let headers : @http.Headers = Map([])
  for header in request.headers {
    headers[@http.CaseInsensitiveString(header.name)] = header.value
  }

  match auth_value(request.auth) {
    Some(value) =>
      headers[@http.CaseInsensitiveString("Authorization")] = value
    None => ()
  }

  if request.body is @core.Json(_) &&
    !headers.contains(@http.CaseInsensitiveString("Content-Type")) {
    headers[@http.CaseInsensitiveString("Content-Type")] =
      "application/json"
  }
  headers
}

///|
fn body_text(body : @core.Body) -> String {
  match body {
    Empty => ""
    Text(value) => value
    Json(value) => value
  }
}

///|
fn response_headers(
  headers : @http.Headers,
) -> Array[@core.Header] {
  let result : Array[@core.Header] = []
  for name, value in headers {
    result.push({
      name: name.to_string(),
      value,
    })
  }
  result
}

///|
#warnings("-fragile_catch_all")
async fn execute_http(
  request : @core.Request,
) -> Result[@core.Response, @core.ProbeError] {
  let url = append_query(request.url, request.query)
  let headers = build_headers(request)
  let body = body_text(request.body)
  let start = @async.now()

  try {
    let (raw_response, raw_body) = @http.request(
      url,
      request_method(request.http_method),
      headers,
      body,
    )
    let text = raw_body.text()
    let elapsed = (@async.now() - start).to_int()
    Ok(
      @core.new_response(
        raw_response.code,
        response_headers(raw_response.headers),
        text,
        elapsed,
      ),
    )
  } catch {
    err =>
      Err(
        @core.TransportError(
          @debug.to_string(err),
        ),
      )
  }
}

///|
pub impl @core.Transport for HttpTransport with fn execute(
  _self,
  request,
  timeout_ms,
) {
  let completed = @async.with_timeout_opt(
    timeout_ms,
    () => execute_http(request),
  )
  match completed {
    Some(result) => result
    None => Err(@core.Timeout(timeout_ms))
  }
}


///|
pub extend HttpTransport with @core.Transport::{execute}
