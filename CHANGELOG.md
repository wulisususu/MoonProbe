# Changelog

All notable changes to MoonProbe will be documented here.

## Unreleased

### 2026-09-21

#### Added

- Initialized public MoonProbe repository.
- Defined API debugging and automated testing product direction.
- Added one-page hackathon project proposal.
- Added product, scope, architecture and public API design documents.
- Added development, test and demo plans.
- Added AI-assisted development policy.
- Added competition submission checklist.
- Adopted Apache License 2.0.
- Added the public MoonBit `core` package.
- Added Method, Header, QueryParam, Body and Auth models.
- Added transport-neutral Request and Response models.
- Added explicit Environment / Variable models and immutable-style set/get helpers.
- Added structured `ProbeError` variants.
- Added black-box Core tests.
- Added Linux / Windows CI with strict `moon check --deny-warn`, tests and builds.

Gate 1 is complete.

#### Template expansion

- Added deterministic single-pass `{{variable}}` expansion.
- Added exact `MissingVariable(name)` errors plus malformed-template validation.
- Added Request-wide rendering for URL, headers, query parameters, body and auth.
- Added Unicode, repeated-variable, missing-variable and immutability tests.
- Verified template changes on Linux and Windows CI.

#### Assertion engine

- Added structured `Assertion` and `AssertionResult` models.
- Added status equality and range assertions.
- Added case-insensitive header existence / contains assertions.
- Added body substring assertions.
- Added minimal object JSON path existence / equality assertions.
- Added response-time assertions.
- Added ordered multi-assertion evaluation and aggregate pass state.
- Hardened CI with installer retries, `actions/checkout@v5`, and non-fail-fast matrix execution.
- Verified assertion changes on Linux and Windows CI.

Gate 2 is complete.

#### Transport and single-request runner

- Added the replaceable async `Transport` trait to Core.
- Added structured `RequestResult` and `run_request` orchestration.
- Added FakeTransport runner tests for success, render failures, transport failures and timeout validation.
- Added `HttpTransport` backed by `moonbitlang/async@0.22.1`.
- Added GET / POST / PUT / PATCH / DELETE / HEAD / OPTIONS method mapping.
- Added RFC 3986 Query parameter encoding.
- Added Bearer and UTF-8 + Base64 Basic authentication.
- Added JSON content-type handling, response header capture and elapsed-time measurement.
- Added deadline cancellation mapped to structured `Timeout`.
- Added real loopback HTTP integration tests with no public-network dependency.
- Added white-box encoding tests while keeping real transport execution black-box.
- CI now refreshes the Mooncakes registry with `moon update` before dependency resolution.
- Verified real HTTP execution and timeout behavior on Linux and Windows.

Gate 3 is complete.

#### Collection runner and reporting

- Added `CollectionRequest`, `Collection`, and `CollectionResult` public Core models.
- Added ordered `run_collection` execution over the existing replaceable Transport trait.
- Added per-request assertions and timeout configuration inside Collections.
- Added continue-on-failure as the default execution policy.
- Added stop-on-failure with explicit `skipped` accounting for requests that were never executed.
- Added cumulative transport duration, executed/passed/failed/skipped counts, and stable pass state.
- Added a five-request Todo Collection regression scenario.
- Added coverage for assertion failure, transport error, stop-on-failure, continue-on-failure, and empty Collections.
- Added an independent `report/` package with Text and JSON reporters.
- Added stable machine-readable schema `moonprobe.collection-report.v1`.
- JSON reports preserve null response fields for transport failures and structured error kind/message data.
- Reporter tests validate summaries, failed assertions, early-stop output, schema version and timeout serialization.

Gate 4 is complete.

#### Native CLI

- Added a thin `cli/` adapter plus `cmd/moonprobe` executable.
- Added `moonprobe send <request.json>` for one-request execution.
- Added `moonprobe run <collection.json>` for ordered Collection execution.
- Added `--env <env.json>` environment loading.
- Added `--format text|json` output selection over the existing Reporter package.
- Added stable exit codes: 0 pass, 1 executed failure, 2 input/configuration error.
- Added JSON input parsing for Methods, Headers, Query Params, JSON/Text Body, Bearer/Basic Auth, timeout and Assertions.
- Added Collection and Environment JSON input parsing.
- Kept CLI wire-format DTO logic outside Core so file-format concerns do not become foundation-library API constraints.
- Implemented `send` by wrapping the request as a single-item Collection, reusing the same Runner and Reporter paths.
- Added example Request, Collection, and Environment files.
- Added parser tests for valid/default/error paths plus Help/Version execution tests.
- Added `moonbitlang/x/sys` for portable nonzero native exit codes.
- Verified the native executable and CLI packages on Linux and Windows.

Gate 5 is complete.

#### Web Playground

- Extracted JSON input parsing from CLI into reusable pure-MoonBit `wire/` package.
- CLI now consumes the shared wire parser instead of owning a private parser copy.
- Added `playground_bridge/` as a JavaScript-target MoonBit foreign library.
- Exported `prepare_request_json` to parse Request/Environment input and apply Core template rendering before browser IO.
- Exported `evaluate_response_report_json` to evaluate browser response data with the Core Assertion Engine and return the existing versioned report schema.
- Added Node ABI smoke coverage that imports the generated ESM module and calls both exported bridge functions.
- Added a responsive API workbench with Method/URL/Send, Body/Headers/Params/Auth/Tests editors, Response Viewer and assertion results.
- Added a five-request Todo API collection backed by a CORS-friendly public demo endpoint.
- Added ordered one-click browser collection execution and per-request result indicators.
- Added explicit browser CORS messaging; Native CLI remains the unrestricted network transport.
- Added GitHub Pages workflow that compiles the MoonBit JS Bridge and stages it with the static playground.
- Added JS target check/build to CI and syntax validation for the browser module.

Gate 6 is complete.

#### Submission hardening

- Added a development retrospective covering architecture decisions, AI-assisted workflow, testing strategy and corrected assumptions.
- Added direct dependency / GitHub Actions license review and credential-review notes.
- Aligned the one-page proposal and competition checklist with the implemented v0.1 scope.
- Added a zero-configuration public demo environment backed by JSONPlaceholder for CLI review.
- Added a 60-second reviewer quickstart.
- Updated README examples so reviewers can execute the public demo without editing configuration first.

Gate 7 is in final verification.
