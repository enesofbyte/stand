# Stand — Development roadmap & milestones

This file outlines the phased plan to implement Stand from prototype → MVP → production-ready app.

## Phase 0 — Research & prototype (current)
- Architecture and data model design
- Flutter prototype: vault, markdown editor, indexing & search, AI service stub
- UI/UX and wireframes

## Phase 1 — MVP (1-2 sprints)
Goals: a usable, offline-first Android app with the core flows.

Core features
- Multi-vault local storage and file management
- WYSIWYG/Markdown editor + live preview + media attachments
- Basic backlinks + tags + YAML frontmatter
- Task, Habit, Journal models (local DB)
- Database views: simple list and kanban
- Local metadata index (SQLite + FTS) and fuzzy search
- Basic AI panel (summarize, extract tasks)
- Export/Import and backups

Quality
- Unit tests for storage and indexing
- Basic integration tests

## Phase 2 — Beta (3-4 sprints)
- Advanced block editor (re-order, inline DB blocks, slash commands)
- CRDT support for collaborative edits or improved merge handling
- Expanded database views: calendar, charts
- Rich AI agents: auto-fill, structured outputs, embeddings
- Sync adapters: WebDAV, Git, optional StandSync server
- Widgets, share extension, and biometric lock

## Phase 3 — Production & Growth
- E2EE sync & server offering
- Plugin marketplace and third-party connectors
- Desktop apps (Flutter desktop) and mobile OS integrations
- Performance refinements and large vault scaling

## Milestone timeline (example)
- Week 1–2: Completed architecture, data model, UI flows (done)
- Week 3–4: Implement core vault, editor, indexing and basic AI flows (POC — in repo)
- Week 5–8: Implement full editor UX (block model), tasks/habits engine, DB views
- Week 9–12: Sync adapters and CRDT evaluation; private beta

---
I can now continue implementing the next items in the MVP pipeline — which would you like me to do next (search polish, editor features, tasks/habits, onboarding or AI deep integrations)?
