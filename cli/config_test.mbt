///|
test "parse send command with env and json output" {
  assert_eq(
    @cli.parse_args(
      [
        "send",
        "request.json",
        "--env",
        "dev.json",
        "--format",
        "json",
      ][:],
    ),
    Ok({
      command: @cli.Send("request.json"),
      env_path: Some("dev.json"),
      output_format: @cli.JsonOutput,
    }),
  )
}

///|
test "parse run command defaults to text output" {
  assert_eq(
    @cli.parse_args(["run", "collection.json"][:]),
    Ok({
      command: @cli.Run("collection.json"),
      env_path: None,
      output_format: @cli.TextOutput,
    }),
  )
}

///|
test "parse help and version" {
  assert_eq(
    @cli.parse_args(["--help"][:]),
    Ok({
      command: @cli.Help,
      env_path: None,
      output_format: @cli.TextOutput,
    }),
  )
  assert_eq(
    @cli.parse_args(["--version"][:]),
    Ok({
      command: @cli.Version,
      env_path: None,
      output_format: @cli.TextOutput,
    }),
  )
}

///|
test "parse rejects invalid formats and missing paths" {
  assert_eq(
    @cli.parse_args(["send"][:]),
    Err("send requires a JSON file path"),
  )
  assert_eq(
    @cli.parse_args(["run", "x.json", "--format", "xml"][:]),
    Err("--format must be text or json"),
  )
}
