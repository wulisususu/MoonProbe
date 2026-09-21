///|
/// Execute Collection requests in declaration order.
///
/// A failed request means template, transport, or assertion failure. When
/// stop_on_failure is enabled the failing RequestResult is retained and the
/// remaining requests are counted as skipped.
pub async fn[T : Transport] run_collection(
  collection : Collection,
  env : Environment,
  transport : T,
) -> CollectionResult {
  let results : Array[RequestResult] = []
  let mut passed = 0
  let mut failed = 0
  let mut duration_ms = 0
  let mut stopped_early = false

  for item in collection.requests {
    let result = run_request(
      item.request,
      env,
      item.assertions,
      transport,
      timeout_ms=item.timeout_ms,
    )
    let did_pass = request_result_passed(result)
    match result.response {
      Some(response) => duration_ms += response.duration_ms
      None => ()
    }
    results.push(result)

    if did_pass {
      passed += 1
    } else {
      failed += 1
      if collection.stop_on_failure {
        stopped_early = true
        break
      }
    }
  }

  let total = collection.requests.length()
  let executed = results.length()
  {
    collection_name: collection.name,
    total,
    executed,
    passed,
    failed,
    skipped: total - executed,
    duration_ms,
    stopped_early,
    requests: results,
  }
}
