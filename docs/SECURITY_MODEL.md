# MoonProbe Security Model

## Scope

MoonProbe handles HTTP requests and may temporarily process credentials such as API tokens. Security boundaries must be explicit from the first version.

## Secrets

MoonProbe must not:

- commit secrets into repository examples;
- print Authorization values by default in reports;
- persist secrets to logs without explicit user action;
- include real credentials in Demo data.

## Redaction

Reporters should support redaction for sensitive headers, at minimum:

```text
Authorization
Proxy-Authorization
Cookie
Set-Cookie
X-API-Key
```

The exact API will be defined during implementation.

## Web Playground

Browser execution is constrained by CORS and the browser security model.

The public Demo must not silently forward arbitrary private requests through an undeclared server-side proxy.

If a relay is introduced:

- it must be documented;
- credentials handling must be explained;
- SSRF protections must be considered;
- the Demo must clearly distinguish local/browser behavior from relay behavior.

## CLI

CLI output should avoid echoing secrets.

Machine-readable JSON reports should redact sensitive headers by default unless the user explicitly enables unsafe raw output.

## Fixtures

Only fictitious tokens, users, URLs and payloads are allowed in committed fixtures.
