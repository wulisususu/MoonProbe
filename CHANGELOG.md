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

Gate 2 remains in progress; Assertion Engine is next.
