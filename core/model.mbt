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

pub extend Method with Eq::{not_equal, equal}
pub extend Method with @debug.Debug::{to_repr}

///|
/// Convert a Method to the canonical HTTP token.
pub fn method_to_string(http_method : Method) -> String {
  match http_method {
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

pub extend Header with Eq::{not_equal, equal}
pub extend Header with @debug.Debug::{to_repr}

///|
/// A single URL query parameter.
pub(all) struct QueryParam {
  name : String
  value : String
} derive(Eq, @debug.Debug)

pub extend QueryParam with Eq::{not_equal, equal}
pub extend QueryParam with @debug.Debug::{to_repr}

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

pub extend Body with Eq::{not_equal, equal}
pub extend Body with @debug.Debug::{to_repr}

///|
/// Authentication configuration supported by the MVP.
pub(all) enum Auth {
  NoAuth
  Bearer(String)
  Basic(String, String)
} derive(Eq, @debug.Debug)

pub extend Auth with Eq::{not_equal, equal}
pub extend Auth with @debug.Debug::{to_repr}

///|
/// A transport-neutral HTTP request description.
pub(all) struct Request {
  name : String
  http_method : Method
  url : String
  headers : Array[Header]
  query : Array[QueryParam]
  body : Body
  auth : Auth
} derive(Eq, @debug.Debug)

pub extend Request with Eq::{not_equal, equal}
pub extend Request with @debug.Debug::{to_repr}

///|
/// Build a minimal request with empty headers/query/body and no auth.
pub fn new_request(
  name : String,
  http_method : Method,
  url : String,
) -> Request {
  {
    name,
    http_method,
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

pub extend Response with Eq::{not_equal, equal}
pub extend Response with @debug.Debug::{to_repr}

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
