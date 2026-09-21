///|
/// A named value used later by MoonProbe template expansion.
pub(all) struct Variable {
  name : String
  value : String
} derive(Eq, @debug.Debug)

pub extend Variable with Eq::{not_equal, equal}
pub extend Variable with @debug.Debug::{to_repr}

///|
/// An explicit environment rather than an implicit process-global map.
///
/// Keeping values inside a data structure makes collection execution
/// deterministic and easy to test.
pub(all) struct Environment {
  values : Array[Variable]
} derive(Eq, @debug.Debug)

pub extend Environment with Eq::{not_equal, equal}
pub extend Environment with @debug.Debug::{to_repr}

///|
/// Create an empty environment.
pub fn empty_environment() -> Environment {
  { values: [] }
}

///|
/// Create an environment from explicit variables.
pub fn environment(values : Array[Variable]) -> Environment {
  { values, }
}

///|
/// Find a variable by exact name.
pub fn environment_get(env : Environment, name : String) -> String? {
  for item in env.values {
    if item.name == name {
      return Some(item.value)
    }
  }
  None
}

///|
/// Return a new environment with name set to value.
///
/// If the variable already exists, the new value replaces it. Input arrays are
/// copied so callers do not observe hidden mutation.
pub fn environment_set(
  env : Environment,
  name : String,
  value : String,
) -> Environment {
  let next : Array[Variable] = []
  let mut replaced = false
  for item in env.values {
    if item.name == name {
      next.push({ name, value })
      replaced = true
    } else {
      next.push(item)
    }
  }
  if !replaced {
    next.push({ name, value })
  }
  { values: next }
}
