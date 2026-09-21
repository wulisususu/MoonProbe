///|
fn parse_json(text : String, label : String) -> Result[Json, String] {
  try {
    Ok(@json.parse(text))
  } catch {
    (_ : @json.ParseError) => Err("invalid JSON in \{label}")
  }
}

///|
fn required_string(
  object : Map[String, Json],
  key : String,
) -> Result[String, String] {
  match object.get(key) {
    Some(String(value)) => Ok(value)
    Some(_) => Err("field '\{key}' must be a string")
    None => Err("missing required field '\{key}'")
  }
}

///|
fn optional_bool(
  object : Map[String, Json],
  key : String,
  default : Bool,
) -> Result[Bool, String] {
  match object.get(key) {
    None | Some(Null) => Ok(default)
    Some(True) => Ok(true)
    Some(False) => Ok(false)
    Some(_) => Err("field '\{key}' must be a boolean")
  }
}

///|
fn optional_int(
  object : Map[String, Json],
  key : String,
  default : Int,
) -> Result[Int, String] {
  match object.get(key) {
    None | Some(Null) => Ok(default)
    Some(Number(value, ..)) => Ok(value.to_int())
    Some(_) => Err("field '\{key}' must be a number")
  }
}

///|
fn required_int(
  object : Map[String, Json],
  key : String,
) -> Result[Int, String] {
  match object.get(key) {
    Some(Number(value, ..)) => Ok(value.to_int())
    Some(_) => Err("field '\{key}' must be a number")
    None => Err("missing required field '\{key}'")
  }
}

///|
fn scalar_text(value : Json) -> String {
  match value {
    String(text) => text
    _ => value.stringify()
  }
}

///|
fn parse_method(value : String) -> Result[@core.Method, String] {
  match value.to_upper() {
    "GET" => Ok(@core.GET)
    "POST" => Ok(@core.POST)
    "PUT" => Ok(@core.PUT)
    "PATCH" => Ok(@core.PATCH)
    "DELETE" => Ok(@core.DELETE)
    "HEAD" => Ok(@core.HEAD)
    "OPTIONS" => Ok(@core.OPTIONS)
    other => Err("unsupported HTTP method: \{other}")
  }
}

///|
fn parse_name_value_array(
  object : Map[String, Json],
  key : String,
) -> Result[Array[(String, String)], String] {
  let result : Array[(String, String)] = []
  match object.get(key) {
    None | Some(Null) => Ok(result)
    Some(Array(items)) => {
      for item in items {
        guard item is Object(fields) else {
          return Err("entries in '\{key}' must be objects")
        }
        let name = match required_string(fields, "name") {
          Ok(value) => value
          Err(message) => return Err("\{key}: \{message}")
        }
        let value = match required_string(fields, "value") {
          Ok(value) => value
          Err(message) => return Err("\{key}: \{message}")
        }
        result.push((name, value))
      }
      Ok(result)
    }
    Some(_) => Err("field '\{key}' must be an array")
  }
}

///|
fn parse_body(object : Map[String, Json]) -> @core.Body {
  match object.get("body") {
    None | Some(Null) => @core.Empty
    Some(String(value)) => @core.Text(value)
    Some(value) => @core.Json(value.stringify())
  }
}

///|
fn parse_auth(object : Map[String, Json]) -> Result[@core.Auth, String] {
  match object.get("auth") {
    None | Some(Null) => Ok(@core.NoAuth)
    Some(Object(auth)) => {
      let auth_type = match required_string(auth, "type") {
        Ok(value) => value.to_lower()
        Err(message) => return Err("auth: \{message}")
      }
      match auth_type {
        "none" => Ok(@core.NoAuth)
        "bearer" =>
          match required_string(auth, "token") {
            Ok(token) => Ok(@core.Bearer(token))
            Err(message) => Err("auth: \{message}")
          }
        "basic" => {
          let username = match required_string(auth, "username") {
            Ok(value) => value
            Err(message) => return Err("auth: \{message}")
          }
          let password = match required_string(auth, "password") {
            Ok(value) => value
            Err(message) => return Err("auth: \{message}")
          }
          Ok(@core.Basic(username, password))
        }
        _ => Err("auth.type must be none, bearer, or basic")
      }
    }
    Some(_) => Err("field 'auth' must be an object")
  }
}

///|
fn parse_assertion(value : Json) -> Result[@core.Assertion, String] {
  guard value is Object(object) else {
    return Err("assertion must be an object")
  }
  let kind = match required_string(object, "type") {
    Ok(value) => value
    Err(message) => return Err(message)
  }

  match kind {
    "status_is" =>
      match required_int(object, "expected") {
        Ok(expected) => Ok(@core.StatusIs(expected))
        Err(message) => Err(message)
      }
    "status_between" => {
      let min = match required_int(object, "min") {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      let max = match required_int(object, "max") {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      Ok(@core.StatusBetween(min, max))
    }
    "header_exists" =>
      match required_string(object, "name") {
        Ok(name) => Ok(@core.HeaderExists(name))
        Err(message) => Err(message)
      }
    "header_contains" => {
      let name = match required_string(object, "name") {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      let expected = match required_string(object, "value") {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      Ok(@core.HeaderContains(name, expected))
    }
    "body_contains" =>
      match required_string(object, "value") {
        Ok(expected) => Ok(@core.BodyContains(expected))
        Err(message) => Err(message)
      }
    "json_exists" =>
      match required_string(object, "path") {
        Ok(path) => Ok(@core.JsonExists(path))
        Err(message) => Err(message)
      }
    "json_equals" => {
      let path = match required_string(object, "path") {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      match object.get("expected") {
        Some(expected) => Ok(@core.JsonEquals(path, scalar_text(expected)))
        None => Err("missing required field 'expected'")
      }
    }
    "response_time_less_than" =>
      match required_int(object, "ms") {
        Ok(ms) => Ok(@core.ResponseTimeLessThan(ms))
        Err(message) => Err(message)
      }
    _ => Err("unsupported assertion type: \{kind}")
  }
}

///|
fn parse_assertions(
  object : Map[String, Json],
) -> Result[Array[@core.Assertion], String] {
  let result : Array[@core.Assertion] = []
  match object.get("assertions") {
    None | Some(Null) => Ok(result)
    Some(Array(values)) => {
      for value in values {
        match parse_assertion(value) {
          Ok(assertion) => result.push(assertion)
          Err(message) => return Err("assertions: \{message}")
        }
      }
      Ok(result)
    }
    Some(_) => Err("field 'assertions' must be an array")
  }
}

///|
fn parse_collection_request_json(
  value : Json,
) -> Result[@core.CollectionRequest, String] {
  guard value is Object(object) else {
    return Err("request document must be a JSON object")
  }

  let name = match required_string(object, "name") {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let method_text = match required_string(object, "method") {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let http_method = match parse_method(method_text) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let url = match required_string(object, "url") {
    Ok(value) => value
    Err(message) => return Err(message)
  }

  let header_pairs = match parse_name_value_array(object, "headers") {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let headers : Array[@core.Header] = []
  for pair in header_pairs {
    let (header_name, header_value) = pair
    headers.push({ name: header_name, value: header_value })
  }

  let query_pairs = match parse_name_value_array(object, "query") {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let query : Array[@core.QueryParam] = []
  for pair in query_pairs {
    let (query_name, query_value) = pair
    query.push({ name: query_name, value: query_value })
  }

  let auth = match parse_auth(object) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let assertions = match parse_assertions(object) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let timeout_ms = match optional_int(object, "timeout_ms", 10000) {
    Ok(value) => value
    Err(message) => return Err(message)
  }

  Ok(
    @core.collection_request(
      {
        name,
        http_method,
        url,
        headers,
        query,
        body: parse_body(object),
        auth,
      },
      assertions,
      timeout_ms~,
    ),
  )
}

///|
fn parse_request_document(
  text : String,
  label : String,
) -> Result[@core.CollectionRequest, String] {
  match parse_json(text, label) {
    Ok(value) => parse_collection_request_json(value)
    Err(message) => Err(message)
  }
}

///|
fn parse_collection_document(
  text : String,
  label : String,
) -> Result[@core.Collection, String] {
  let root = match parse_json(text, label) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  guard root is Object(object) else {
    return Err("collection document must be a JSON object")
  }

  let name = match required_string(object, "name") {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let stop_on_failure = match optional_bool(object, "stop_on_failure", false) {
    Ok(value) => value
    Err(message) => return Err(message)
  }

  guard object.get("requests") is Some(Array(values)) else {
    return Err("field 'requests' must be an array")
  }
  let requests : Array[@core.CollectionRequest] = []
  for value in values {
    match parse_collection_request_json(value) {
      Ok(request) => requests.push(request)
      Err(message) => return Err("requests: \{message}")
    }
  }

  Ok(@core.new_collection(name, requests, stop_on_failure~))
}

///|
fn parse_environment_document(
  text : String,
  label : String,
) -> Result[@core.Environment, String] {
  let root = match parse_json(text, label) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  guard root is Object(object) else {
    return Err("environment document must be a JSON object")
  }

  let variables : Array[@core.Variable] = []
  for name, value in object {
    match value {
      String(text) => variables.push({ name, value: text })
      _ => return Err("environment value '\{name}' must be a string")
    }
  }
  Ok(@core.environment(variables))
}
