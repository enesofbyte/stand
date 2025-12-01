# Stand — UI/UX flows & wireframes (mobile-first)

This document captures the proposed UI navigation, main screens and wireframes for the Android app (mobile-first). The design emphasizes quick capture, offline-first vault interaction, a powerful yet streamlined editor, and integrated AI helpers.

## Navigation model
- Root bottom navigation with 5 primary sections (customizable):
  1. Home / Dashboard
  2. Vault / Explorer
  3. Editor / Scratchpad (Quick-capture)
  4. Database / Views
  5. Profile / Settings

## Screen wireframes (text)

### 1) Home / Dashboard
- Header: date, quick stat tiles (habits, todays tasks, streaks)
- Middle: Timeline / recent activity / Today quick actions
- Widgets: Graphs for habit streaks, mood, task completion
- AI panel shortcut: Summaries / insights

### 2) Vault / Explorer
- Top bar: Vault switcher (left), search (center), new page (Quick Add)
- Body: Folder tree + recent pages list + pinned pages
- Right: (slide-over) page preview + quick actions (tag, link, add task)

### 3) Editor / Page view
- Editor toolbar: undo, redo, style, slash commands, block menu
- Dual mode: Read / Write toggle — split view for live preview
- Blocks list: inline block drag handle, drag & reorder
- Footer: breadcrumbs (path), page properties summary, backlinks count

Editor mobile specifics:
- Touch-first block selection, long-press for context menu
- Mobile QuickBar (bottom): snippet insert, media attach, mic, camera
- Keyboard shortcuts (hardware): CMD/Ctrl + O quick switch

### 4) Database / Views
- Top: DB selector + view switcher (table, board, calendar, gallery)
- Filters/sorts bar: multi-filter chips
- Body: DB presentation depending on view
- Inline edit: tap a record to open quick-edit modal

### 5) Tasks / Habit / Journal (integrated into DB)
- Dedicated tab or integrated into Dashboard depending on user preference
- Task detail: title, description blocks, due, recurrence, reminders, relations
- Habit: current streak, calendar heatmap, logs, pause/resume
- Journal timeline: day-by-day entries, mood graph, related notes

## Editor interactions & gestures
- Swipe left on a block to reveal options (delete, duplicate, convert to task)
- Long press to reorganize blocks
- Slash command menu: /todo /habit /embed /db /date /img /code

## AI Panel (always reachable from Editor)
- Context area: current note + selected blocks + recent related pages
- Suggested actions list: Summarize, Extract tasks, Create DB record, Auto-tag
- Chat interface: ask for re-writes, translations, or expand ideas

## Quick-capture & Widgets
- Quick-capture widget: pick vault, choose type (note, task, voice memo)
- Share sheet extension for Android: Save selected text or media quickly
- Home screen widget: add entry, show today’s tasks and habit progress

## Onboarding flows
1. Choose or create a vault (local or cloud)
2. Optional: Import from markdown folder / Obsidian / Notion export
3. Offer sample templates (journal, project board, habit)

## Accessibility and performance
- Clean contrast and font sizes, adjustable line-width; support for large text
- Operate offline-first and keep media optimized (thumbs and streaming)

---
Next: start implementing the first features — project scaffold already added; I'll move to implement a local vault module and the editor POC in Flutter (proof-of-concept) next.
