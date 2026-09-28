# Chapt Admin Panel (WriteRead)

Flutter admin app for managing **Chapt** comics, chapters, pricing, and
per-language content for the mobile reader.

## Run

```bash
flutter pub get
flutter run -d chrome   # or any desktop / device target
```

Sign in with an account that has a document in Firestore `admins/{uid}`.

## Who can use it

Only users listed under the `admins` collection can manage comics. Non-admin
sign-ins are signed out automatically.

## Editor playbook — localization

Chapt ships UI + comic content in **11 languages**:
`en`, `es`, `pt`, `fr`, `ja`, `ko`, `de`, `id`, `th`, `vi`, `tr`.

### Mental model

| Piece | Rule |
|-------|------|
| English | Canonical. Lives on the **root** comic document (`title`, `description`, `chapters`, cover). |
| Other languages | Stored under `locales.{code}` (never put `en` there). |
| Metadata | Title / description / category: locale value if set, else English in the app. |
| Cover | Optional per locale; missing cover → English cover in the app. |
| Chapters | **Independent per language.** No English chapter fallback. Empty list → app shows “Coming soon”. |

### Readiness chips (Ready / Partial / Missing)

- **Ready** — title + description + at least one chapter with pages (EN uses root fields).
- **Partial** — some content started, not complete.
- **Missing** — nothing useful for that language yet.

Home grid badges and the comic **Localization overview** matrix use the same rules.

### Recommended workflow per comic

1. Create the comic in **English** (title, description, category, product ID, cover).
2. Add English chapters with page images (and optional music).
3. Open each language tab (or tap the matrix cell):
   - **Save locale metadata** (or Copy from English, then translate).
   - Optionally upload a locale cover.
   - Add that language’s chapters separately (pages must be uploaded again — they are not shared with EN).
4. Watch the matrix until target languages are **Ready**.
5. Save metadata before switching language (unsaved changes show a discard dialog).

### Storage paths (do not invent paths)

| Locale | Cover | Pages / music |
|--------|-------|----------------|
| `en` | `Comics/{comicId}_cover.jpg` | `Comics/{comicId}/{chapterId}/{n}.jpeg` |
| other | `Comics/{comicId}/{locale}/cover.jpg` | `Comics/{comicId}/{locale}/{chapterId}/{n}.jpeg` |

Helpers: `lib/core/locale/app_locales.dart`, `lib/core/locale/chapter_storage_paths.dart`.

Full shared contract: see Comics-App `docs/LOCALIZATION.md` and this repo’s
`docs/LOCALIZATION.md`.

## Session

The app root is an **AuthGate**:

- Signed out → Sign-in
- Signed in → admin check → Home
- Home AppBar → **Sign out**

Restarting the app while signed in returns you to Home (not Sign-in).

## Project layout (high level)

- `lib/presentation/home` — catalog grid
- `lib/presentation/comic` — comic detail, chapters, locale editor
- `lib/presentation/auth` — sign-in + session gate
- `lib/domain` / `lib/data` — use cases and Firebase sources
