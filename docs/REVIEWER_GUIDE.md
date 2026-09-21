# Reviewer Quickstart

This is the shortest path to verify MoonProbe v0.1.

## 1. Verify the MoonBit project

~~~bash
moon update
moon check --target native --deny-warn
moon test --target native
moon build --target native
~~~

Expected result: check/build succeed and the test suite passes.

## 2. Run one API request

This command uses the public JSONPlaceholder endpoint and needs no credential:

~~~bash
moon run cmd/moonprobe -- send examples/requests/get-user.json   --env examples/env/public-demo.json   --format text
~~~

The request exercises:

~~~text
JSON file
  ↓
wire parser
  ↓
Environment + {{base_url}} / {{token}}
  ↓
Native HttpTransport
  ↓
status / JSON assertions
  ↓
Text Report
~~~

## 3. Run a Collection

~~~bash
moon run cmd/moonprobe -- run examples/collections/todo-api.json   --env examples/env/public-demo.json   --format json
~~~

The JSON output uses schema:

~~~text
moonprobe.collection-report.v1
~~~

## 4. Verify the browser bridge

The repository CI additionally compiles `playground_bridge/` with the JavaScript backend, imports the generated ESM in Node, and calls the exported MoonBit bridge functions.

The browser adapter reuses MoonBit for:

- request/environment JSON parsing;
- template rendering;
- assertion evaluation;
- versioned report generation.

Browser JavaScript is responsible for `fetch`, timeout control and UI state only.

## 5. Architecture in one minute

~~~text
                    MoonProbe Core
                         │
       ┌─────────────────┼─────────────────┐
       ▼                 ▼                 ▼
 Request/Template   Assertion Engine   Collection Runner
       │                 │                 │
       └─────────────────┼─────────────────┘
                         ▼
                 CollectionResult
                         │
                    Text / JSON
                         │
             ┌───────────┴───────────┐
             ▼                       ▼
        Native CLI             Web Playground
             │                       │
      HttpTransport             browser fetch
                                     │
                              MoonBit JS Bridge
~~~

The key design rule is simple: deleting `playground/` does not remove the reusable MoonBit testing engine.

## Network note

The two quickstart commands use a public endpoint for convenience, so they require internet access.

The automated regression suite does not depend on that endpoint: real HTTP integration tests use a local loopback server, and Core orchestration uses FakeTransport where possible.
