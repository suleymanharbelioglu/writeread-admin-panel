# Localization (shared with Chapt mobile)

See Comics-App `docs/LOCALIZATION.md` for the full contract.

Quick rules for this admin panel:

- Root comic document = English
- Other languages under `locales.{code}` (never `en`)
- Chapters are **independent per locale** (no EN chapter fallback). Empty locale chapters → app “Coming soon”
- Add/delete chapters from each language tab separately
- EN cover: `Comics/{comicId}_cover.jpg`
- Locale cover (optional): `Comics/{comicId}/{locale}/cover.jpg` → field `locales.{code}.image`
- Missing locale cover → app uses English cover
- EN pages: `Comics/{comicId}/{chapterId}/{n}.jpeg`
- Other: `Comics/{comicId}/{locale}/{chapterId}/{n}.jpeg`
- Helpers: `lib/core/locale/app_locales.dart`, `lib/core/locale/chapter_storage_paths.dart`

## Readiness

Used by home badges and the comic localization matrix:

- **Ready** — title + description + ≥1 chapter with pages
- **Partial** — started but incomplete
- **Missing** — no useful content yet

English uses root fields; other languages use `locales.{code}`.

## Editor tips

1. Finish English first.
2. Per language: metadata → optional cover → independent chapters.
3. Save locale metadata before switching language tabs.
4. “Copy from English” only fills metadata fields — not pages.
