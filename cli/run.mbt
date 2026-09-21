///|
async fn read_text_file(path : String) -> Result[String, String] {
  try {
    Ok(@fs.read_file(path).text())
  } catch {
    error =>
      Err("failed to read '\{path}': \{@debug.to_string(error)}")
  }
}

///|
async fn load_environment(path : String?) -> Result[@core.Environment, String] {
  match path {
    None => Ok(@core.empty_environment())
    Some(value) => {
      let text = match read_text_file(value) {
        Ok(content) => content
        Err(message) => return Err(message)
      }
      parse_environment_document(text, value)
    }
  }
}

///|
fn render_collection(
  result : @core.CollectionResult,
  output_format : OutputFormat,
) -> String {
  match output_format {
    TextOutput => @report.collection_report_text(result)
    JsonOutput => @report.collection_report_json(result)
  }
}

///|
/// Execute a fully parsed CLI command.
///
/// This function returns an outcome instead of terminating the process so the
/// executable boundary remains thin and testable.
pub async fn execute(config : CliConfig) -> Result[CliOutcome, String] {
  match config.command {
    Help => Ok({ output: usage(), exit_code: 0 })
    Version => Ok({ output: "MoonProbe 0.1.0", exit_code: 0 })
    Send(path) => {
      let text = match read_text_file(path) {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      let request = match parse_request_document(text, path) {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      let env = match load_environment(config.env_path) {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      let collection = @core.new_collection(
        "Request: \{request.request.name}",
        [request],
      )
      let result = @core.run_collection(
        collection,
        env,
        @transport.HttpTransport::new(),
      )
      Ok({
        output: render_collection(result, config.output_format),
        exit_code: if @core.collection_result_passed(result) { 0 } else { 1 },
      })
    }
    Run(path) => {
      let text = match read_text_file(path) {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      let collection = match parse_collection_document(text, path) {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      let env = match load_environment(config.env_path) {
        Ok(value) => value
        Err(message) => return Err(message)
      }
      let result = @core.run_collection(
        collection,
        env,
        @transport.HttpTransport::new(),
      )
      Ok({
        output: render_collection(result, config.output_format),
        exit_code: if @core.collection_result_passed(result) { 0 } else { 1 },
      })
    }
  }
}
