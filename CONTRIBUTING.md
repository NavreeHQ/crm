# Contributing to the CRM

The CRM is the reference application for Navree. Changes that make it a better example of a Navree app are welcome. Changes to the framework itself belong in [NavreeHQ/navree](https://github.com/NavreeHQ/navree), whose [CONTRIBUTING.md](https://github.com/NavreeHQ/navree/blob/main/CONTRIBUTING.md) has the conventions for commits, tests and documentation. They apply here too.

## Build and test

```sh
cargo test --workspace                                    # the API
pnpm --dir web install && pnpm --dir web typecheck && pnpm --dir web test
pnpm --dir nuxt install && pnpm --dir nuxt typecheck && pnpm --dir nuxt test
```

`README.md` shows how to run the API and the front ends. The browser journeys (`pnpm --dir web e2e`, `pnpm --dir nuxt e2e`) start a real API and a real browser; run them when you change a screen.

## Rules

- One change per pull request, with a test beside the code. A screen changes with its journey.
- Commit messages read `type(scope): what the code now does`, for example `feat(deals): move a deal with the keyboard`.
- The framework is asked for the way an app of yours asks for it (`navree = "1"`, `"@navree/next": "^1.0.0"`); the lock files hold the exact versions. Move to a new framework release with `cargo update` and `pnpm update`, in a pull request of its own. Dependabot updates the other libraries.
- Demo data is Indian: Punjabi and North Indian names, Indian cities, rupees written with lakh grouping (₹1,00,000), IST and +91 phone numbers.
- Check your change against the framework's main branch with `scripts/use-framework.sh ../navree` before you open a pull request that depends on an unreleased framework change.

## License

Your contribution comes in under the project's terms: MIT or Apache-2.0, at the user's option (section 5 of the Apache License). There is no contributor agreement to sign.
