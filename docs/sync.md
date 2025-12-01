# Stand — Sync & backup options

Stand is offline-first, but sync is a core feature for multi-device workflows. This document lays out the supported sync backends, security model and conflict-resolution approaches.

## Supported sync backends (MVP → advanced)

1. Local-only (default)
   - User keeps vault locally on the device — no cloud sync.

2. WebDAV / Nextcloud / OwnCloud (recommended for users)
   - Simple to support and users retain control of storage.
   - Use standard WebDAV endpoints and sync file diffs.
   - Support background sync using Android WorkManager.

3. Git-backed sync (power users)
   - Vault is a Git repo; syncing performed by commit/push/pull.
   - Pros: versioning, user control, diff transparency. Cons: merge conflicts and complexity.

4. Optional StandSync server (advanced)
   - Custom server with E2EE and conflict-resolution services.
   - Server stores encrypted blobs and performs no plaintext processing unless allowed.

## Security & encryption

- Vault-level encryption (AES-256) with passphrase.
- Keys stored in the platform's secure store (Android Keystore). Biometric unlock supported for convenience.
- For cloud sync, support E2EE: client encrypts files before upload and manages keys locally. Sync server stores only ciphertext.

## Conflict resolution approaches

1. CRDT (recommended long-term)
   - Use CRDTs to handle concurrent block edits without conflicts.
   - Complexity higher, but offers a smooth UX and low manual merge need.

2. Last-write-wins + manual merge (MVP)
   - Simpler to implement for a first release.
   - Show visual merge UI with diffs when LWW detects conflicting changes.

3. Hybrid (files + block-level)
   - Use file-based sync for most and enable CRDT for hot-editing sessions and collaborative editing.

## Sync operation modes

- Periodic background sync (configurable interval)
- On-change sync (watch file system and push changes)
- Pause/resume and manual conflict resolution UI

## Backup & restore

- Local scheduled backups (zip of vault with optional encryption)
- Export/Import: .zip and .md folder import
- Snapshot history maintained by the metadata DB (with retention policy)

## Integration considerations

- Offer per-vault sync policy and migrate vaults between modes (local → webdav → server).
- Provide transparent reporting of sync status, conflicts and last synced time.

---
Next: create a development roadmap with milestones and initial sprint plan.
