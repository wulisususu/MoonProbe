# AGENTS.md

This repository is a MoonBit-first hackathon project.

## Product Goal

MoonProbe is an API debugging and automated testing workbench backed by a reusable MoonBit core.

The core rule for every implementation decision:

> If the Web Playground is deleted, the MoonBit Core must still be useful, testable, and reusable.

## Repository Priorities

1. Core models and deterministic behavior
2. Tests
3. CLI / reusable API
4. Demo
5. Visual polish

## Expected Structure

```text
core/
cli/
examples/
tests/
playground/
docs/
```

## MoonBit Coding Rules

- Prefer explicit typed models over loosely structured strings.
- Keep errors structured and pattern-matchable.
- Separate pure logic from IO where possible.
- Transport must be replaceable in tests.
- New public behavior requires tests.
- Run formatter/check/tests before considering a task complete.
- Do not duplicate Runner logic in the UI.

## Documentation Rules

Do not claim planned features are already implemented.

When implementation changes reality, update at least:

- README.md
- docs/API_DESIGN.md when public API changes
- docs/COMPETITION_CHECKLIST.md when a gate is completed
- CHANGELOG.md for meaningful milestones

## Security

Never commit real:

- API keys
- Bearer tokens
- cookies
- credentials
- private user data

Use fixtures and fake values.

## AI-assisted Development

AI suggestions must be reviewed and validated. See docs/AI_USAGE.md.
