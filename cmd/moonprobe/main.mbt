///|
async fn main {
  let argv = @env.args()
  let args : Array[String] = []
  for index in 1..<argv.length() {
    args.push(argv[index])
  }

  let config = match @app.parse_args(args[:]) {
    Ok(value) => value
    Err(message) => {
      @stdio.stderr.write("error: \{message}\n\n")
      @stdio.stderr.write(@app.usage())
      @sys.exit(2)
      return
    }
  }

  match @app.execute(config) {
    Err(message) => {
      @stdio.stderr.write("error: \{message}\n")
      @sys.exit(2)
    }
    Ok(outcome) => {
      @stdio.stdout.write(outcome.output)
      if !outcome.output.has_suffix("\n") {
        @stdio.stdout.write("\n")
      }
      if outcome.exit_code != 0 {
        @sys.exit(outcome.exit_code)
      }
    }
  }
}
