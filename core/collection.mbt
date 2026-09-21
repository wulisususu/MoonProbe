///|
/// One request inside a Collection, including the assertions and timeout used
/// when the ordered runner reaches it.
pub(all) struct CollectionRequest {
  request : Request
  assertions : Array[Assertion]
  timeout_ms : Int
} derive(Eq, @debug.Debug)

pub extend CollectionRequest with Eq::{not_equal, equal}
pub extend CollectionRequest with @debug.Debug::{to_repr}

///|
/// Build a Collection request with the default 10 second timeout.
pub fn collection_request(
  request : Request,
  assertions : Array[Assertion],
  timeout_ms? : Int = 10000,
) -> CollectionRequest {
  { request, assertions, timeout_ms }
}

///|
/// Ordered group of API requests.
pub(all) struct Collection {
  name : String
  requests : Array[CollectionRequest]
  stop_on_failure : Bool
} derive(Eq, @debug.Debug)

pub extend Collection with Eq::{not_equal, equal}
pub extend Collection with @debug.Debug::{to_repr}

///|
/// Build a Collection. By default failures do not stop later requests.
pub fn new_collection(
  name : String,
  requests : Array[CollectionRequest],
  stop_on_failure? : Bool = false,
) -> Collection {
  { name, requests, stop_on_failure }
}

///|
/// Structured result of an ordered Collection run.
///
/// duration_ms is the cumulative duration reported by executed transports,
/// rather than wall-clock overhead inside the runner.
pub(all) struct CollectionResult {
  collection_name : String
  total : Int
  executed : Int
  passed : Int
  failed : Int
  skipped : Int
  duration_ms : Int
  stopped_early : Bool
  requests : Array[RequestResult]
} derive(Eq, @debug.Debug)

pub extend CollectionResult with Eq::{not_equal, equal}
pub extend CollectionResult with @debug.Debug::{to_repr}

///|
/// A Collection passes when every executed request passed and nothing was
/// skipped because of stop-on-failure.
pub fn collection_result_passed(result : CollectionResult) -> Bool {
  result.failed == 0 && result.skipped == 0
}
