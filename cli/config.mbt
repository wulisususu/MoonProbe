///|
/// CLI output representation.
pub(all) enum OutputFormat {
  TextOutput
  JsonOutput
} derive(Eq, @debug.Debug)

pub extend OutputFormat with Eq::{equal, not_equal}
pub extend OutputFormat with @debug.Debug::{to_repr}

///|
/// Supported MoonProbe CLI commands.
pub(all) enum CliCommand {
  Send(String)
  Run(String)
  Help
  Version
} derive(Eq, @debug.Debug)

pub extend CliCommand with Eq::{equal, not_equal}
pub extend CliCommand with @debug.Debug::{to_repr}

///|
/// Fully parsed CLI configuration.
pub(all) struct CliConfig {
  command : CliCommand
  env_path : String?
  output_format : OutputFormat
} derive(Eq, @debug.Debug)

pub extend CliConfig with Eq::{equal, not_equal}
pub extend CliConfig with @debug.Debug::{to_repr}

///|
/// Process outcome. Exit code 0 means all checks passed, 1 means the executed
/// request/collection failed, and argument/input errors are handled as code 2
/// by the executable boundary.
pub(all) struct CliOutcome {
  output : String
  exit_code : Int
} derive(Eq, @debug.Debug)

pub extend CliOutcome with Eq::{equal, not_equal}
pub extend CliOutcome with @debug.Debug::{to_repr}

///|
pub fn usage() -> String {
  #|MoonProbe
  #|
  #|Usage:
  #|  moonprobe send <request.json> [--env <env.json>] [--format text|json]
  #|  moonprobe run <collection.json> [--env <env.json>] [--format text|json]
  #|  moonprobe --help
  #|  moonprobe --version
  #|
  #|Exit codes:
  #|  0  all requests/assertions passed
  #|  1  request or collection executed but failed
  #|  2  invalid CLI arguments, input files, or configuration
  #|
}

///|
fn parse_output_format(value : String) -> Result[OutputFormat, String] {
  match value {
    "text" => Ok(TextOutput)
    "json" => Ok(JsonOutput)
    _ => Err("--format must be text or json")
  }
}

///|
/// Parse user arguments after argv[0].
pub fn parse_args(args : ArrayView[String]) -> Result[CliConfig, String] {
  if args.length() == 0 {
    return Err("missing command")
  }

  match args[0] {
    "--help" | "-h" =>
      if args.length() == 1 {
        return Ok({
          command: Help,
          env_path: None,
          output_format: TextOutput,
        })
      } else {
        return Err("--help does not accept extra arguments")
      }
    "--version" =>
      if args.length() == 1 {
        return Ok({
          command: Version,
          env_path: None,
          output_format: TextOutput,
        })
      } else {
        return Err("--version does not accept extra arguments")
      }
    "send" | "run" => ()
    other => return Err("unknown command: \{other}")
  }

  if args.length() < 2 {
    return Err("\{args[0]} requires a JSON file path")
  }

  let file = args[1]
  let mut env_path : String? = None
  let mut output_format = TextOutput
  let mut index = 2

  while index < args.length() {
    match args[index] {
      "--env" => {
        if index + 1 >= args.length() {
          return Err("--env requires a file path")
        }
        env_path = Some(args[index + 1])
        index += 2
      }
      "--format" => {
        if index + 1 >= args.length() {
          return Err("--format requires text or json")
        }
        match parse_output_format(args[index + 1]) {
          Ok(value) => output_format = value
          Err(message) => return Err(message)
        }
        index += 2
      }
      other => return Err("unknown option: \{other}")
    }
  }

  Ok({
    command: if args[0] == "send" { Send(file) } else { Run(file) },
    env_path,
    output_format,
  })
}
