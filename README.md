# Stand — LifeOS / PKM Android (prototype)

Stand is an offline-first, Markdown-based LifeOS, Personal Knowledge Management and productivity app with AI integrations. This repository contains design docs and an early Flutter prototype skeleton.

Repository layout (work-in-progress):

- /docs — architecture, data model and design documents
- /app/flutter — lightweight Flutter app skeleton to prototype the UI and local modules

Next steps (short-term plan):
1. Implement local vault handling and .md read/write from app
2. Build the block-based WYSIWYG editor and live preview
3. Implement metadata index (SQLite + FTS) and search
4. Add task/habit models and UI
5. AI agent integration for helpers and auto-fill

See docs/architecture.md and docs/data-model.md for details.

To run the Flutter skeleton (if you have Flutter SDK installed):

```bash
cd app/flutter
# If you don't have platform files yet, create them:
# flutter create .
flutter pub get
flutter run -d <device>
```

For building APKs and signing, see `docs/build-and-sign.md` and the `.github/workflows` directory which includes both a debug APK CI and an example Release workflow that consumes a base64-encoded keystore secret.

# stand