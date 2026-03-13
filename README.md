# Setup Arcium

A GitHub Action for installing and setting up the Arcium CLI and tooling.

## Usage

Here's an example workflow:

```yaml
name: example-workflow
on: [push]
jobs:
  run-arcium-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: arcium-hq/setup-arcium@v0.9.0
        with:
          runner-arch-os: x86_64_linux
      - run: arcium build
        shell: bash
```

This will use the default versions:

- Arcium: 0.9.0
- Anchor: 0.32.1
- Node.js: 20.18.0
- Solana CLI: 2.3.0

The `runner-arch-os` parameter is required. Options: `x86_64_linux`, `aarch64_macos`.

### Custom Versions

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: arcium-hq/setup-arcium@v0.9.3
    with:
      arcium-version: "0.9.3"
      anchor-version: "0.32.1"
      solana-cli-version: "2.3.0"
      node-version: "20.18.0"
      runner-arch-os: x86_64_linux
```

### Running Tests on Linux

When running `arcium test` on Linux CI, you must increase the file descriptor limit in the same shell to prevent `Too many open files` errors from solana-test-validator:

```yaml
- name: Test
  run: |
    sudo prlimit --pid $$ --nofile=1048576:1048576
    arcium test
  shell: bash
```

> **Note:** This is required because each GitHub Actions step runs in a separate shell.

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE).
