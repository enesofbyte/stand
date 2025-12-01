# Stand — Data model and file formats

This document specifies the core data formats and schema ideas used by Stand for the vault, notes, blocks, database records, tasks, habits, and journal entries.

## Vault & .md file layout

- Vault root: /<vault-name>/
  - metadata.db (SQLite index & search)
  - .stand/config.json (vault-level config: id, encryption, sync settings)
  - /pages/*.md (text files saved as Markdown with YAML frontmatter)
  - /media/* (images, audio, video, pdf)

### Example note file
---
id: 9f2b3a4e-3dcb-4e2d-9dff-39c0a6a1a574
title: Meeting notes — Marketing Q3
aliases: ["marketing Q3 meeting"]
tags: [ # tag using nested dot syntax
  "work.product",
  "team.marketing"
]
created_at: 2025-12-01T09:10:00Z
updated_at: 2025-12-01T10:05:00Z
type: page
db_refs: []
status: draft
properties:
  importance: 2
  attendees:
    - alice@example.com
    - bob@example.com
---

# Meeting notes — Marketing Q3

Welcome — meeting summary

> Block JSON fallback:

<!-- blocks: [{"id":"b1","type":"heading","level":1,"text":"Meeting notes — Marketing Q3"},{"id":"b2","type":"paragraph","text":"Welcome — meeting summary"}] -->


The above file uses YAML frontmatter for metadata and a classic Markdown body. For live editor use we may also store an internal compact block JSON representation inside comments for fast reconstructions.

## Block model

- Blocks are the atomic building blocks of the editor (heading, paragraph, list, checklist, code, math, table, image, audio, video, toggle, callout, divider, database-inline).
- Standard JSON representation:

{
  "id": "uuid",
  "type": "paragraph|heading|list|checklist|code|image|...",
  "text": "",
  "children": [ ... ],
  "meta": { "language": "dart|js", "checked": false }
}

Block JSON is used to: render the WYSIWYG editor, handle block-level slash commands, and convert to/from markdown.

## Block-embedded Markdown conversion rules
- Each block maps to one or more markdown structures. The editor maintains both a canonical block JSON and a human-readable markdown body. The canonical block representation survives round trips and editing.

## Database record models (conceptual)

All records have:
- id (uuid)
- created_at, updated_at
- vault_id
- properties (key-value map — typed)

### Note record (index/metadata)
- id (uuid) — points to filename
- title
- path (relative to vault)
- tags (array of tag strings)
- aliases
- backlinks_count
- outgoing_links
- excerpt

### Task record
- id
- title
- description (optional)
- created_at, updated_at
- due_date (optional)
- repeat_rule (cron-like or RFC5545 RRULE)
- status (todo, in-progress, done)
- priority
- reminders []
- relations -> link to other page ids

### Habit record
- id
- name
- start_date
- frequency (daily, weekly, custom pattern)
- targets (e.g., times/day) and streaks
- logs: timestamped check events

### Journal entry
- id
- date
- mood (enum + score)
- text
- tags
- attachments

### Database (table) record
- databases are first-class objects with defined schema
- property types: text, number, select, multi-select, status, date, files, url, checkbox, relation

## Relation & Rollups
- Relation property: a list of references to other records
- Rollup property: aggregate function (count, sum, min, max, latest) over a relation's property

## Indexing & Search
- SQLite with FTS5 to index note bodies and metadata
- Secondary indices for tags, aliases, properties, backlinks

## Versioning
- Vault metadata model version (semantic): stored in .stand/manifest.json
- Migration system to handle upgrades when schema or block format changes

## Example: Task to .md mapping

Task saved as /pages/tasks/call-client.md
---
id: fd7b9d0a-...
title: Call Acme client
type: task
status: todo
due_date: 2025-12-02T15:00:00Z
repeat_rule: "RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR"
properties:
  project: Acme Migration
  estimated_minutes: 30
---

Description, notes, and block content follow.

---
Next: prepare UI/UX wireframes and the developer plan for the Flutter implementation.
