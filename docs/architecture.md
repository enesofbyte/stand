# Stand — Architecture overview

This document describes the high-level architecture for Stand: a LifeOS, PKM, Journal, Habit/Task/Database Android app with offline-first vaults, block-based editor, database views, and AI integrations.

## High-level goals
- Offline-first, local vaults stored as Markdown (.md) files with YAML frontmatter for metadata.
- Block-based/ WYSIWYG editor with slash commands and live preview.
- Multi-vault support and safe sync options (E2EE, WebDAV/Nextcloud, optional server).
- Extensible AI agent for context-aware operations (summarize, generate tasks, auto-fill DB properties).

## Core components

1. Frontend: Flutter (Dart)
   - Single codebase for Android/iOS with performant UI and native integrations (camera, mic, share sheet, widgets).
   - UI modules: Vault Manager, File Explorer, Page Viewer/Editor, Blocks/Renderer, Database Viewer(UI: table/board/gallery/calendar), Journal, Task/Habits, AI panel, Settings.

2. Local Storage / File System
   - Vault contains hierarchical folders with .md files and media assets (images, audio, video, PDFs).
   - Each .md file: YAML frontmatter + markdown body. Blocks stored inline as markdown block types and a compact Block JSON representation for internal use.
   - Metadata store (lightweight DB) for fast search & indexing (e.g., SQLite or RocksDB).

3. Backend / Sync (optional)
   - No mandatory cloud service (offline-first). Several sync backends supported:
     - WebDAV / Nextcloud / OwnCloud
     - Git-backed sync (for power users)
     - Optional custom server (Rust/Go/Node) with E2EE support for secure cloud sync
   - Conflict resolution: CRDT-based (recommended) or last-write-wins with manual merge UI.

4. AI Agent
   - Local context manager that prepares summary context windows from vault and DB records.
   - Plug-in abstraction: commands (CREATE_FILE, UPDATE_DB, CREATE_TASK) with authorization and undo.
   - LLM integration: remote LLM provider or local LLM (if available); responses cached and indexed.

5. Sync & Security
   - Local passphrase-based encryption for vaults (AES-256) and optional end-to-end sync.
   - Biometric unlock (Android keystore / iOS Secure Enclave) for convenience.

6. Analytics & Telemetry
   - Optional opt-in telemetry for crash reporting and usage analytics.

## Inter-component communication
- Flutter UI interacts with a domain layer written in Dart.
- Local persistence: a small Rust/Go native extension (via FFI) is optional for performance (search, full-text index) and sync heavy-lifting.
- Background services (Android WorkManager / iOS background tasks) manage periodic sync, backups and AI indexing.

## Technology choices & trade-offs
- Flutter gives cross-platform UI and fast iteration.
- SQLite is the default metadata index with FTS (full-text search) for speed. Optional high-perf index in native language if required.
- CRDTs are the preferred approach for conflict-free multi-device editing; if that's heavy initially, fallback to LWW + manual merge.

## Minimal first-phase implementation (MVP scope)
1. Core vault: multi-vault local filesystem using .md files and media folder
2. Basic editor: read/write markdown with live preview + simple block support
3. Metadata index: SQLite for tags, backlinks, and quick search
4. Tasks/habits: simple DB-backed models with recurring rules
5. AI: pluggable LLM client, first implementation using a remote provider (OpenAI/compatible) for summarization and helper prompts

---
Next: define file formats and data models (YAML frontmatter schema, block json model, DB models for tasks/habits/journal).  
