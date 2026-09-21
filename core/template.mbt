///|
/// Expand MoonProbe {{variable}} placeholders in a string.
///
/// Expansion is single-pass: values inserted from the environment are written
/// verbatim and are not recursively interpreted as templates.
pub fn render_template(
  input : String,
  env : Environment,
) -> Result[String, ProbeError] {
  let output = StringBuilder()
  let mut cursor = 0

  while cursor < input.length() {
    let remaining = input[cursor:]
    match remaining.find("{{") {
      None => {
        output.write_view(remaining)
        cursor = input.length()
      }
      Some(open_rel) => {
        let open_pos = cursor + open_rel
        if open_pos > cursor {
          output.write_view(input[cursor:open_pos])
        }

        let name_start = open_pos + 2
        let after_open = input[name_start:]
        match after_open.find("}}") {
          None =>
            return Err(
              InvalidRequest("unclosed template variable"),
            )
          Some(close_rel) => {
            let close_pos = name_start + close_rel
            let name = input[name_start:close_pos].to_owned()
            if name.length() == 0 {
              return Err(
                InvalidRequest("template variable name must not be empty"),
              )
            }

            match environment_get(env, name) {
              None => return Err(MissingVariable(name))
              Some(value) => output.write_string(value)
            }
            cursor = close_pos + 2
          }
        }
      }
    }
  }

  Ok(output.to_string())
}

///|
/// Render all templatable fields in one request.
///
/// The source Request is not mutated.
pub fn render_request(
  request : Request,
  env : Environment,
) -> Result[Request, ProbeError] {
  let rendered_url = match render_template(request.url, env) {
    Ok(value) => value
    Err(err) => return Err(err)
  }

  let rendered_headers : Array[Header] = []
  for header in request.headers {
    let name = match render_template(header.name, env) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    let value = match render_template(header.value, env) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    rendered_headers.push({ name, value })
  }

  let rendered_query : Array[QueryParam] = []
  for param in request.query {
    let name = match render_template(param.name, env) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    let value = match render_template(param.value, env) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    rendered_query.push({ name, value })
  }

  let rendered_body = match request.body {
    Empty => Empty
    Text(value) =>
      match render_template(value, env) {
        Ok(rendered) => Text(rendered)
        Err(err) => return Err(err)
      }
    Json(value) =>
      match render_template(value, env) {
        Ok(rendered) => Json(rendered)
        Err(err) => return Err(err)
      }
  }

  let rendered_auth = match request.auth {
    NoAuth => NoAuth
    Bearer(token) =>
      match render_template(token, env) {
        Ok(rendered) => Bearer(rendered)
        Err(err) => return Err(err)
      }
    Basic(username, password) => {
      let rendered_username = match render_template(username, env) {
        Ok(value) => value
        Err(err) => return Err(err)
      }
      let rendered_password = match render_template(password, env) {
        Ok(value) => value
        Err(err) => return Err(err)
      }
      Basic(rendered_username, rendered_password)
    }
  }

  Ok({
    name: request.name,
    http_method: request.http_method,
    url: rendered_url,
    headers: rendered_headers,
    query: rendered_query,
    body: rendered_body,
    auth: rendered_auth,
  })
}
