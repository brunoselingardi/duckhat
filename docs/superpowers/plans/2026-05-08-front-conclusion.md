# DuckHat Front Conclusion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish the current frontend phase by making the app internally consistent after the Connect-API-Backend integration, reducing visible mock/fallback areas, and validating the main client and provider flows.

**Architecture:** Keep Flutter screens wired through `DuckHatApi` and existing models instead of adding parallel state. Public establishment pages should consume real catalog/profile data first and only show empty states for backend gaps; provider/shop screens should use real authenticated endpoints where available. Leave backend contract changes for a separate backend task unless a frontend flow is impossible without a small DTO/API addition.

**Tech Stack:** Flutter/Dart, Spring Boot API, MySQL local Docker, `flutter_test`, Maven tests.

---

## Current Verification Snapshot

- Branch after rebase: `newfrontL...origin/newfrontL [ahead 9, behind 11]`.
- `flutter analyze`: passing after local fixes.
- `flutter test`: passing with 30 tests after local fixes.
- `./mvnw test`: passing with 43 tests.
- `git diff --check`: passing.
- Local uncommitted fixes currently touch:
  - `lib/shop_pages/shop_establishment_data.dart`
  - `test/appointment_detail_test.dart`
  - `test/service_page_test.dart`

## File Structure

- `lib/pages/service.dart`: public establishment page orchestration; remove remaining fallback dependency where real catalog data exists.
- `lib/components/service/service_sections.dart`: decide which sections render when gallery/reviews/FAQ have no real data.
- `lib/components/service/service_experience_section.dart`: remove or wire local CTA.
- `lib/components/service/service_profile_fallbacks.dart`: keep only temporary demo content or shrink usage.
- `lib/pages/search_results.dart`: search result behavior; internal provider cards must consistently open `ServicePage(prestadorId: ...)`.
- `lib/pages/promotions.dart`: static promotion data; either connect to real provider pages honestly or mark as local prototype.
- `lib/pages/home.dart` and `lib/components/home/rebook.dart`: home/rebook data shape; replace loose `List`/map usage with a typed view model if touched.
- `lib/shop_pages/shop_gallery.dart`, `shop_work_days.dart`, `shop_work_hours.dart`, `shop_notifications.dart`, `shop_privacy.dart`, `shop_help.dart`, `shop_about.dart`: currently local/demo provider subpages; decide hide, label as local, or connect.
- `docs/funcionalidades-por-arquivo.md`: keep the real-vs-local matrix accurate after each change.

---

### Task 1: Stabilize Repository State

**Files:**
- Modify: `lib/shop_pages/shop_establishment_data.dart`
- Modify: `test/appointment_detail_test.dart`
- Modify: `test/service_page_test.dart`
- Check: Git branch state

- [ ] **Step 1: Confirm no rebase is active**

Run:

```bash
git status --short --branch
```

Expected:

```text
## newfrontL...origin/newfrontL [ahead 9, behind 11]
 M lib/shop_pages/shop_establishment_data.dart
 M test/appointment_detail_test.dart
 M test/service_page_test.dart
```

- [ ] **Step 2: Commit the test/analyze stabilization fixes**

Run:

```bash
git add lib/shop_pages/shop_establishment_data.dart test/appointment_detail_test.dart test/service_page_test.dart
git commit -m "test: align frontend tests after api merge"
```

Expected: one commit with only the three stabilization files.

- [ ] **Step 3: Decide remote reconciliation strategy**

Do not push while the branch is `ahead` and `behind`. Choose one:

```bash
git fetch origin
git status --short --branch
```

If the remote branch contains work that must be preserved, prefer a normal merge from `origin/newfrontL` into local `newfrontL` and resolve conflicts. Do not force-push without explicit approval.

---

### Task 2: Finish Public Establishment Page Behavior

**Files:**
- Modify: `lib/pages/service.dart`
- Modify: `lib/components/service/service_sections.dart`
- Modify: `lib/components/service/service_experience_section.dart`
- Test: `test/service_page_test.dart`

- [ ] **Step 1: Add tests for empty real catalog sections**

Extend `test/service_page_test.dart` so the Jorje catalog case asserts:

```dart
expect(find.text('Nenhuma avaliação publicada ainda.'), findsOneWidget);
expect(find.text('Nenhuma pergunta frequente cadastrada.'), findsOneWidget);
expect(find.text('Serviços e preços'), findsOneWidget);
expect(find.text('Visita tecnica de encanador'), findsOneWidget);
```

Also assert that fallback brand content does not leak:

```dart
expect(find.text('Barbie Dream Barber'), findsNothing);
```

- [ ] **Step 2: Hide or neutralize non-real sections**

In `ServiceSections`, render gallery/reviews/FAQ only when data exists or when the section has an explicit empty state. Keep current empty states for reviews/FAQ; for gallery, prefer an empty state over demo assets when the provider is not one of the hardcoded demo providers.

- [ ] **Step 3: Remove unwired local CTA from experience**

In `service_experience_section.dart`, either remove the CTA or pass a real callback from `ServicePage`. Default should be no CTA when there is no handler.

- [ ] **Step 4: Verify**

Run:

```bash
flutter test test/service_page_test.dart
flutter analyze
```

Expected: tests pass and no analyzer issues.

---

### Task 3: Tighten Search-To-Provider Flow

**Files:**
- Modify: `lib/pages/search_results.dart`
- Modify: `lib/services/search_intent.dart` only if synonym coverage is missing
- Test: `test/search_page_test.dart`

- [ ] **Step 1: Add regression coverage for internal provider navigation**

Add or extend a widget/unit test that verifies the internal result for `encanador` carries `prestadorId=13` and is treated as an internal DuckHat result, not as an external Geoapify-only card.

- [ ] **Step 2: Normalize known service terms before internal catalog search**

Confirm `SearchIntent` maps generic plumbing terms to `encanador`. If missing, add synonyms like:

```dart
'vazamento',
'desentupimento',
'hidraulica',
'hidráulica',
'cano',
'pia',
'ralo',
```

- [ ] **Step 3: Verify**

Run:

```bash
flutter test test/search_page_test.dart test/search_intent_test.dart
flutter analyze
```

Expected: internal catalog path is covered and no analyzer issues.

---

### Task 4: Decide Static Promotion Surface

**Files:**
- Modify: `lib/pages/promotions.dart`
- Modify: `docs/funcionalidades-por-arquivo.md`
- Optional Test: new focused widget test if behavior changes

- [ ] **Step 1: Choose current product behavior**

For this phase, do not invent a promotions backend. Use one of these explicit frontend choices:

```text
Option A: keep promotions as a local prototype and document it clearly.
Option B: remove the home CTA until promotions are real.
Option C: keep curated local offers but make every CTA open SearchPage or a known ServicePage honestly.
```

Recommended for current scope: Option C.

- [ ] **Step 2: Remove misleading static provider names**

If keeping local offers, ensure copy does not imply live discount inventory. CTAs should open either:

```dart
const SearchPage()
```

or a known internal provider:

```dart
const ServicePage(prestadorId: 2)
```

- [ ] **Step 3: Verify**

Run:

```bash
flutter analyze
flutter test
```

Expected: full Flutter suite passes.

---

### Task 5: Provider Area Final Pass

**Files:**
- Review: `lib/shop_pages/shop_profile.dart`
- Review: `lib/shop_pages/shop_gallery.dart`
- Review: `lib/shop_pages/shop_work_days.dart`
- Review: `lib/shop_pages/shop_work_hours.dart`
- Review: `lib/shop_pages/shop_notifications.dart`
- Review: `lib/shop_pages/shop_privacy.dart`
- Review: `lib/shop_pages/shop_help.dart`
- Modify: `docs/funcionalidades-por-arquivo.md`

- [ ] **Step 1: Classify each provider subpage**

Use this table:

```text
Real: shop_home, shop_schedule, shop_clients, shop_profile, shop_establishment_data, shop_service_duration
Local/demo: shop_gallery, shop_work_days, shop_work_hours, shop_notifications, shop_privacy, shop_help, shop_about
```

- [ ] **Step 2: Remove front-door access to unfinished local pages if needed**

If a local page creates product confusion, hide its menu item from `shop_profile.dart` instead of opening `SnackBar('Em breve')`.

- [ ] **Step 3: Keep docs honest**

Update `docs/funcionalidades-por-arquivo.md` after menu changes. The docs must clearly say which provider pages are real and which are local/demo.

- [ ] **Step 4: Verify**

Run:

```bash
flutter analyze
flutter test
git diff --check
```

Expected: clean.

---

### Task 6: Manual End-To-End Validation

**Files:**
- No code changes expected
- Update: `docs/funcionalidades-por-arquivo.md` only if behavior differs from docs

- [ ] **Step 1: Start local API stack**

Run:

```bash
docker compose -f database/compose.yaml --env-file database/.env up -d
cd backend
./mvnw spring-boot:run
```

- [ ] **Step 2: Validate catalog endpoints**

Run:

```bash
curl -s http://127.0.0.1:8081/api/health
curl -s http://127.0.0.1:8081/api/catalogo/estabelecimentos/13
curl -s 'http://127.0.0.1:8081/api/catalogo/estabelecimentos/busca?termo=encanador'
```

Expected: health OK and `Jorje Encanamentos` with `prestadorId=13`.

- [ ] **Step 3: Validate on physical Android**

Run:

```bash
adb -s RX8N309MYQA reverse tcp:8081 tcp:8081
flutter run -d RX8N309MYQA \
  --dart-define=API_BASE_URL=http://127.0.0.1:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456 \
  --dart-define=GEOAPIFY_API_KEY="$GEOAPIFY_API_KEY"
```

Manual checks:

```text
Cliente login -> buscar "encanador" -> abrir Jorje Encanamentos -> enviar mensagem -> agendar serviço
Prestador login encanador@duckhat.com -> ver agenda -> confirmar/concluir atendimento
Cliente -> detalhe concluído -> enviar avaliação
```

Expected: all navigations preserve the correct `prestadorId`.

---

## Completion Criteria

- `git status --short --branch` is clean on `newfrontL`.
- `flutter analyze` passes.
- `flutter test` passes.
- `./mvnw test` passes.
- `git diff --check` passes.
- Public establishment page uses real catalog/profile data and no longer leaks unrelated demo content for real providers.
- Search result for `encanador` opens `Jorje Encanamentos` with `prestadorId=13`.
- Provider area has no misleading front-door links to unfinished local/demo screens.
- Manual Android validation is recorded in the vault.

