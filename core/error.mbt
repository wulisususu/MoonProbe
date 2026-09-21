///|
/// Structured errors shared by MoonProbe core layers.
///
/// Transports and UIs can map platform-specific failures into this stable
/// domain-level model.
pub(all) enum ProbeError {
  InvalidRequest(String)
  InvalidUrl(String)
  InvalidHeader(String)
  MissingVariable(String)
  TransportError(String)
  Timeout(Int)
  InvalidResponse(String)
  AssertionFailure(String)
  CollectionError(String)
} derive(Eq, @debug.Debug)
