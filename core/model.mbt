///|
/// HTTP methods supported by the MoonProbe MVP.
pub(all) enum Method {
  GET
  POST
  PUT
  PATCH
  DELETE
  HEAD
  OPTIONS
} derive(Eq, @debug.Debug)

///|
/// Convert a Method to the canonical HTTP token.
pub fn method_to_string(method : Method) -> String {
  match method {
    GET => "GET"
    POST => "POST"
    PUT => "PUT"
    PATCH => "PATCH"
    DELETE => "DELETE"
    HEAD => "HEAD"
    OPTIONS => "OPTIONS"
  }
}

///|
/// A single HTTP header.
pub(all) struct Header {
  name : String
  value : String
} derive(Eq, @debug.Debug)

///|
/// A single URL query parameter.
pub(all) struct QueryParam {
  name : String
  value : String
} derive(Eq, @debug.Debug)

///|
/// Request body representation for the first MoonProbe release.
///
/// JSON is intentionally stored as text at this layer. Parsing and validation
/// belong to later adapters so the core request model stays transport-neutral.
pub(all) enum Body {
  Empty
  Text(String)
  Json(String)
} derive(Eq, @debug.Debug)

///|
/// Authentication configuration supported by the MVP.
pub(all) enum Auth {
  NoAuth
  Bearer(String)
  Basic(String, String)
} derive(Eq, @debug.Debug)

///|
/// A transport-neutral HTTP request description.
pub(all) struct Request {
  name : String
  method : Method
  url : String
  headers : Array[Header]
  query : Array[QueryParam]
  body : Body
  auth : Auth
} derive(Eq, @debug.Debug)

///|
/// Build a minimal request with empty headers/query/body and no auth.
pub fn new_request(name : String, method : Method, url : String) -> Request {
  {
    name,
    method,
    url,
    headers: [],
    query: [],
    body: Empty,
    auth: NoAuth,
  }
}

///|
/// A transport-neutral HTTP response.
///
/// duration_ms is measured by the transport implementation. The core does not
/// assume how networking is performed.
pub(all) struct Response {
  status : Int
  headers : Array[Header]
  body : String
  duration_ms : Int
} derive(Eq, @debug.Debug)

///|
/// Build a response value, primarily useful to transports and tests.
pub fn new_response(
  status : Int,
  headers : Array[Header],
  body : String,
  duration_ms : Int,
) -> Response {
  { status, headers, body, duration_ms }
}
