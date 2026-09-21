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

Gate 3 is complete. Gate 4 will implement Collection Runner and structured reporting.
