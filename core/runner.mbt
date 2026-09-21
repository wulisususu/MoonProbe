///|
/// Replaceable request execution boundary.
///
/// Core orchestration depends only on this trait. Real HTTP, browser fetch,
/// test doubles, or future replay transports can implement the same contract.
pub(open) trait Transport {
  async fn execute(
    Self,
    Request,
    timeout_ms : Int,
  ) -> Result[Response, ProbeError]
}

///|
/// Result of one fully coordinated MoonProbe request.
pub(all) struct RequestResult {
  request_name : String
  response : Response?
  assertions : Array[AssertionResult]
  error : ProbeError?
} derive(Eq, @debug.Debug)

pub extend RequestResult with Eq::{not_equal, equal}
pub extend RequestResult with @debug.Debug::{to_repr}

///|
/// Run template expansion, transport execution, and assertions in order.
pub async fn[T : Transport] run_request(
  request : Request,
  env : Environment,
  assertions : Array[Assertion],
  transport : T,
  timeout_ms? : Int = 10000,
) -> RequestResult {
  if timeout_ms <= 0 {
    return {
      request_name: request.name,
      response: None,
      assertions: [],
      error: Some(InvalidRequest("timeout_ms must be greater than zero")),
    }
  }

  let rendered = match render_request(request, env) {
    Ok(value) => value
    Err(err) =>
      return {
        request_name: request.name,
        response: None,
        assertions: [],
        error: Some(err),
      }
  }

  match Transport::execute(transport, rendered, timeout_ms) {
    Err(err) => {
      request_name: request.name,
      response: None,
      assertions: [],
      error: Some(err),
    }
    Ok(response) => {
      let results = evaluate_assertions(assertions, response)
      {
        request_name: request.name,
        response: Some(response),
        assertions: results,
        error: None,
      }
    }
  }
}

///|
/// A request passes only when transport succeeded and every assertion passed.
pub fn request_result_passed(result : RequestResult) -> Bool {
  match result.error {
    Some(_) => false
    None => assertions_passed(result.assertions)
  }
}
