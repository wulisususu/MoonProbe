# MoonProbe v0.1.0 Release Notes

MoonProbe v0.1.0 is the first hackathon-ready release of the MoonBit-native API debugging and automated testing workbench.

## Highlights

- typed Request / Response / Environment models;
- deterministic `{{variable}}` template expansion;
- structured status / header / body / JSON / timing assertions;
- replaceable `Transport` trait;
- native HTTP transport with query encoding, auth, body support and timeout handling;
- single-request and ordered Collection execution;
- continue-on-failure and stop-on-failure accounting;
- text and versioned JSON reports;
- native CLI with `send`, `run`, `--env` and `--format`;
- shared MoonBit JSON wire parser;
- MoonBit JavaScript foreign-library bridge;
- browser Playground with Request Builder, Response Viewer, Assertions and one-click Todo Collection;
- Ubuntu / Windows native CI plus JavaScript bridge ABI smoke verification.

## Reviewer path

~~~bash
moon update
moon check --target native --deny-warn
moon test --target native
moon build --target native

moon run cmd/moonprobe -- send examples/requests/get-user.json   --env examples/env/public-demo.json   --format text

moon run cmd/moonprobe -- run examples/collections/todo-api.json   --env examples/env/public-demo.json   --format json
~~~

See [REVIEWER_GUIDE.md](REVIEWER_GUIDE.md) for the architecture and validation path.

## Report schema

Machine-readable output uses:

~~~text
moonprobe.collection-report.v1
~~~

## Known boundaries

v0.1 intentionally does not include:

- OAuth full flows;
- WebSocket / gRPC;
- full JSONPath;
- Postman Collection compatibility;
- cloud sync / collaboration;
- browser relay;
- load testing.

The browser Playground obeys CORS. The Native CLI remains the unrestricted transport path.

## Deployment note

The GitHub Pages workflow is included and successfully builds/stages the MoonBit JavaScript bridge and Playground.

The repository still requires the one-time GitHub Pages setting:

~~~text
Settings → Pages → Build and deployment → Source → GitHub Actions
~~~

After that, re-running the `pages` workflow can publish the live demo.

## Packaging note

`moon.mod` is already versioned as `0.1.0` with Apache-2.0 metadata.

The CI release gate validates package contents with:

~~~bash
moon package --list
~~~

Actual `moon publish` requires a logged-in mooncakes.io account and is intentionally not performed by CI with an unauthenticated token.
