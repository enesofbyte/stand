# Stand — AI Agent design specification

This document explains the AI agent architecture, responsibilities, integration points, and safe operation modes for Stand.

## Goals
- Provide context-aware suggestions, automatic content generation, summarization and DB auto-fill
- Offer safe plugin commands with undo: CREATE_FILE, UPDATE_DB, CREATE_TASK, ATTACH_MEDIA
- Keep user data private and offer opt-in cloud processing; default local processing where feasible

## High-level architecture

1. UI Agent Controller (Flutter)
   - Small UI that gathers user intent (chat or quick actions) and selected context (current note, selected blocks, related pages)
   - Sends the request to the Agent Runtime

2. Agent Runtime (client side)
   - Responsible for preparing context windows, chunking large content, caching embeddings, and orchestrating calls to the LLM provider or local model.
   - Policy engine to ensure user permission for actions that modify vault content (CREATE_FILE, etc.).

3. LLM Provider / Plugin Bridge
   - Connects to remote LLMs (OpenAI, Anthropic, local injector) using secure key storage.
   - Supports streaming responses and structured outputs (JSON when requesting a task creation or DB-fill).

4. Short-term storage & undo
   - All modifications performed by the agent are stored as atomic transactions in a history log with rollback support.

## Context & Prompting
- Build context window from:
  - current note (full or selected block)
  - linked pages (backlinks)
  - DB schema (for auto-fill)
  - recent user actions
- Provide user-configurable prompt templates for each action (summarize, extract tasks, expand, generate follow-ups).

## Commands (pluggable, permissioned)
- CREATE_FILE(PATH, NAME, PROPS): create a new .md with YAML frontmatter
- UPDATE_FILE(PATH, CONTENT): update existing page
- CREATE_TASK({title, due, repeat, rel}): create task record and optionally link to note
- UPDATE_DB(PROPS...): create/update DB entries

Commands must be explicit and require user approval in UI before execution.

## Embeddings & Retrieval
- Use an embeddings service to create vector representations of notes and snippets for similarity search
- Store vectors in a local vector index (SQLite rowstore or optional vector DB). Use to build context windows.

## Security & Privacy
- API keys stored encrypted in platform keystore; user must opt-in for cloud AI features
- Allow per-vault policy: local-only, cloud-only, hybrid
- Rate-limiting and usage reporting (opt-in)

## Example flows

1. User selects a paragraph and clicks 'Summarize -> Draft meeting note'
   - UI sends a summarize request with path + selection
   - Agent returns a draft; user approves; command CREATE_FILE invoked to create a new note

2. User asks 'Extract tasks from this note'
   - Agent extracts tasks as JSON
   - UI shows tasks preview; on confirm, CREATE_TASK is executed for each

## Extensibility
- Add connectors to external services (calendar, tasks, WebDAV), with permission.

---
Next: create a small AI service stub inside the app to demonstrate Summarize action and a UI panel.
