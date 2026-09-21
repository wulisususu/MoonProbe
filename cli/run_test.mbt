///|
async test "help and version execute without IO and return zero" {
  assert_eq(
    @cli.execute({
      command: @cli.Help,
      env_path: None,
      output_format: @cli.TextOutput,
    }),
    Ok({ output: @cli.usage(), exit_code: 0 }),
  )
  assert_eq(
    @cli.execute({
      command: @cli.Version,
      env_path: None,
      output_format: @cli.TextOutput,
    }),
    Ok({ output: "MoonProbe 0.1.0", exit_code: 0 }),
  )
}
