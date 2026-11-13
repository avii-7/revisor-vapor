# Revisor backend

You are a Swift backend developer working on the Revisor Vapor API.

## Project knowledge
- Stack: Swift 6, Vapor 4, Fluent with PostgreSQL, JWT, and FSRS for revision scheduling.
- `Sources/RevisorVapor/` contains application code.
- Features include `Authentication/`, `RevisionItem/`, `Dashboard/`, and `Profile/`.
- Follow existing feature boundaries: controllers handle HTTP, services handle business logic, repositories handle persistence, and mappers convert database models to DTOs.
- `Shared/` contains shared user and pagination code; `Utilities/` contains shared helpers.
- `Database/Migrations/` and `Database/Seeds/` contain schema migrations and seed data.
- `configure.swift` wires application dependencies and middleware; `routes.swift` registers routes.
- `Tests/RevisorVaporTests/` contains Swift Testing tests using VaporTesting.

## Commands
- Build: `swift build`
- Test: `swift test`
- Run locally: `swift run RevisorVapor serve`
- Application startup and tests that call `configure` require the configured environment variables and an available PostgreSQL database. Report missing prerequisites rather than claiming checks passed.
- Do not download or update dependencies without permission.

## Coding practices
- Make small, focused changes that follow existing naming and feature structure.
- Keep business logic out of route registration and controllers; use services and repository abstractions.
- Use async/await and respect Swift concurrency, actor isolation, and `Sendable` requirements. Do not silence concurrency errors with unsafe annotations.
- Validate request data and enforce authentication and user ownership before accessing or changing user records.
- Use DTOs for API responses. Preserve existing snake_case JSON keys and ISO 8601 date encoding unless an API contract change is requested.
- Prefer explicit error handling over new force unwraps. Never log credentials, tokens, or environment secrets.
- Keep database changes in migrations; do not rewrite applied migrations or run destructive database commands without explicit approval.
- Never add tests unless explicitly asked by the user. Run relevant existing checks and disclose failures or checks that could not run.

## Delegation
- Reviewers report findings without editing files. A review request alone does not authorize the parent agent to implement findings.
- Agents inherit session permissions; instructions against editing do not provide a separate read-only sandbox.
- Preserve existing user changes and do not revert unrelated work.

## Boundaries
- Ask before major changes to existing documents.
- Never install dependencies without permission.
- Never edit configuration files or commit secrets without explicit approval.
- Do not modify the frontend project unless the user requests work there.
