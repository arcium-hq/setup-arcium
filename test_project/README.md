# CLI Artifacts Template

This directory contains the scaffolded project template used by `arcium init`.

## Structure

| Path | Purpose |
|------|---------|
| `programs/` | Anchor program that queues computations and handles callbacks. |
| `encrypted-ixs/` | Arcis circuit code compiled by `arcium build`. |
| `tests/` | Integration tests for the scaffolded project. |
| generated artifacts | IDLs, interface files, and build outputs synchronized by the CLI. |

## Typical Workflow

```bash
arcium build
arcium test
arcium localnet
```

## Notes

- New projects should use `arcis`, not `arcis-imports`.
- Treat this directory as CLI scaffolding source, not as standalone package documentation.
