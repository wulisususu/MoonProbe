# Third-Party & License Review

This document records direct dependencies and supporting external components used by MoonProbe v0.1.

## MoonBit module dependencies

| Dependency | Version in MoonProbe | Purpose | License | Review |
| --- | --- | --- | --- | --- |
| `moonbitlang/async` | `0.22.1` | Native async IO, HTTP, filesystem and stdio | Apache-2.0 | Compatible with MoonProbe Apache-2.0 |
| `moonbitlang/x` | `0.4.50` | Native CLI exit code support | Apache-2.0 | Compatible with MoonProbe Apache-2.0 |

Upstream module metadata declares Apache-2.0. MoonProbe does not vendor or modify their source code.

## GitHub Actions

| Action | Version | Purpose | License |
| --- | --- | --- | --- |
| `actions/checkout` | v5 | repository checkout | MIT |
| `actions/configure-pages` | v5 | GitHub Pages configuration | MIT |
| `actions/upload-pages-artifact` | v4 | Pages artifact upload | MIT |
| `actions/deploy-pages` | v4 | Pages deployment | MIT |

These actions are referenced by workflow version tags; their source is not copied into this repository.

## External demo endpoint

The Web Playground defaults to JSONPlaceholder only as a CORS-friendly public test endpoint.

MoonProbe does not bundle JSONPlaceholder source code and Core/CLI do not depend on that service. Users may replace `base_url` with another API.

## MoonBit toolchain

MoonBit is required to build the project but is not redistributed in this repository. Generated JavaScript artifacts are MoonProbe build outputs.

## Source reuse

MoonProbe is an original implementation and is not a port or fork of Postman, Insomnia, Hoppscotch, or another API client.

The project uses common API-client interaction conventions as UI vocabulary, while the models, runner, assertion engine, reporting and adapters are implemented in this repository.

## Credential review

Repository source was reviewed for common credential markers such as `secret`, `api_key`, `password`, and `token`.

No real credentials are intentionally stored.

`examples/env/dev.json` uses:

~~~json
{
  "base_url": "https://api.example.com",
  "token": "replace-me"
}
~~~

The token is an explicit placeholder and must be replaced locally when testing an authenticated API.
