# DuckHat Agent Instructions

## Context

DuckHat is an academic service scheduling app with:

- Flutter frontend in `lib/`
- Spring Boot backend in `backend/`
- MySQL local database managed from `database/`
- Flutter tests in `test/`

The current working repository is:

```text
/home/ludraxter/Projetos/duckhat
```

Do not use the old path `/home/ludraxter/DuckHat/duckhat`.

## Before Changing Code

1. Check the real repository state with `git status --short --branch`.
2. Read the relevant files before editing.
3. Keep changes small and focused.
4. Do not revert or overwrite user changes without explicit approval.
5. Prefer existing project patterns over new abstractions.

## Frontend Rules

- Split large Flutter widgets into smaller components.
- Prefer `const` constructors and `StatelessWidget` where practical.
- Keep business logic out of widget trees when a service/model layer already exists.
- Reuse existing theme tokens from `lib/theme.dart` and nearby components.
- Avoid adding placeholder menu items that only show "Em breve" unless requested.

## Backend Rules

- Keep controllers thin and put business rules in services.
- Keep public catalog endpoints under `/api/catalogo/**`.
- Maintain `ddl-auto=validate`; update migrations whenever entities require schema changes.
- Use the existing test profile with H2 for backend tests.

## Local Validation

Use the commands below according to the files changed:

```bash
flutter analyze
flutter test
git diff --check
```

For backend changes:

```bash
cd backend
./mvnw test
```

For API/manual flow validation, the local backend defaults to:

```text
http://127.0.0.1:8081
```

On the physical Android device `RX8N309MYQA`, apply:

```bash
adb -s RX8N309MYQA reverse tcp:8081 tcp:8081
```

Then run Flutter with:

```bash
flutter run -d RX8N309MYQA \
  --dart-define=API_BASE_URL=http://127.0.0.1:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456
```

Add `GEOAPIFY_API_KEY` by `--dart-define` when validating external location search.

## Current Functional Focus

The public establishment flow is moving from fallback/demo content to real catalog data.

Important validation case:

- Search term: `encanador`
- Provider: `Jorje Encanamentos`
- `prestadorId`: `13`
- Expected flow: search result opens the public page, then chat and scheduling keep using `prestadorId=13`.

