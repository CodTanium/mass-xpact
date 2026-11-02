# Issue #209: Finding: the DLL re-parses the whole document on every XML_Parse call, so input in pieces is slow (F05-1)

Archived from <https://github.com/andersoxie/xpact/issues/209> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-11-02 08:18 |
| Closed |  |
| Labels | `enhancement`, `question`, `type:finding`, `investigation` |
| Milestone | - |

## Description

## 🧭 Overview

xpact is slow when a document arrives **in pieces** (`XML_Parse` called many times). On every call, the DLL parses the **whole document so far again from byte 1** and hides the callbacks the application already received. The work therefore grows with the **square** of the document size.

| Measurement (F05-1, student PC) | xpact | Expat 2.8.1 |
|---|---|---|
| 8 KB of elements, fed 1 byte at a time | **58 s** | **5 ms** |

**@andersoxie — please tick what you want done, and in which order.** Nothing will be changed until you have picked.

- **Cause:** ✅ **confirmed from the code** (the replay path, see below). 🟡 Still to measure: the cost per input size and piece size.
- **Revision:** `student-Mass` @ `22876e9`

---

## 1. ❓ Questions for the supervisor

- [ ] Do you have newer incremental work that is not pushed yet? (Nothing newer than PR #167 is on any branch.)
- [ ] Which approach (A–D below) should come first?
- [ ] Should this be done before the hand-in (27 Nov), or only investigated and written up for later?

## 2. 🛠️ Possible improvements: pick and order

| Pick | Order | | Approach | Expected gain | Size | Risk |
|---|---|---|---|---|---|---|
| [ ] | | **A** | **Finish one prototype** (`XP_INCREMENTAL_PARSE_SESSION` or `XP_EXPAT_PORT_PARSE_SESSION`) and connect it to the DLL | Real streaming, like Expat | 🔴 Very large (weeks) | 🔴 All W3C fixes in `xp_parser.e` would have to be redone |
| [ ] | | **B** | **Checkpoint/resume in the existing parser:** at a safe point between two finished tokens in the element content, save the parser state and drop the bytes already parsed; the next call resumes there instead of at byte 1 | 🟢 Removes the square growth for the document body (most of the bytes) | 🟡 Medium | 🟡 The saved state must be complete; the existing tests check it |
| [ ] | | **C** | **More shortcuts** like the existing ones (plain text, start-tag spaces, unfinished DOCTYPE): add comments, finished end tags, CDATA | 🟡 Only for those cases | 🟢 Small per shortcut | 🟡 More special cases in code that already has many |
| [ ] | | **D** | **Whole-document speed-ups** (continue the PR #167 profile work) | 🟢 10–60 % on whole documents | 🟢 Small | 🟢 Low, but **does nothing for input in pieces** |

**Student's suggestion:** **B** first, then **D** if time allows. A is too big for the time left. C helps only some cases and adds complexity.

## 3. 📋 Steps before any code change

- [ ] **1. Answers** to the questions in section 1
- [ ] **2. Benchmark (the "before" numbers):** 1 KB, 8 KB and 64 KB of elements, fed to xpact and Expat in pieces of 1 byte, 64 bytes and 4 KB. Shows the square growth and gives the before/after numbers. *Can run on Jenkins.*
- [ ] **3. Can B be done? (reading only):** list every piece of state `xp_parser.e` builds while parsing (element stack, namespace scopes, entity tables, line/column, DTD state, pending text, attribute defaults) and check whether it can be saved and restored. `entity_context_snapshot` and the cached DOCTYPE already save part of it. Result: a short design note here.
- [ ] **4. Agree on the tests:** CRC harness (`scripts\run_chunked_crc_corpus.ps1`), shim audit (`scripts\run_incremental_shim_audit.ps1`), test 2 (`reports\issue-0165\tools\run.py`), W3C verdicts and output test. These already check input in pieces, so a speed change must give the **same results as today**.
- [ ] **5. First small step** (its own issue and PR): checkpoint only inside element content, with no DTD and no entities, measured with the benchmark from step 2.

---

## 4. 🔍 Detail: where the replay happens

`src/xp_native_parser.e`, the `XML_Parse` path (lines ~841–1060 @ `22876e9`):

1. `input_buffer.append (a_input)`: the buffer keeps the **whole document so far**.
2. `l_input := decoded_input (input_buffer)`: the whole buffer is decoded again.
3. `handler.prepare_callback_replay (delivered_callback_count)`: the callbacks already delivered will be **suppressed**.
4. `parser.parse_prefix (l_parse_input)`: the **whole buffer is parsed again** from the start.
5. `delivered_callback_count := ... callback_sequence_count`: remember how many to hide next time.

Existing shortcuts that skip the replay: plain ASCII text (`can_append_plain_ascii_text`), spaces in a start tag (`can_append_plain_start_tag_spaces`), an unfinished DOCTYPE (`should_wait_for_doctype_prefix`), a cached DOCTYPE (`parse_with_cached_doctype`), a ready plain start tag (`emit_ready_plain_start_tag_directly`). **Any other markup goes through the full replay.**

## 5. 🧪 Detail: the existing prototypes

| | `XP_INCREMENTAL_PARSE_SESSION` | `XP_EXPAT_PORT_PARSE_SESSION` |
|---|---|---|
| File | `src/xp_incremental_parse_session.e` (623 lines) | `src/xp_expat_port_parse_session.e` (728 lines) |
| Doc | `docs/incremental-core-prototype.md` | `docs/expat-port-spike.md` |
| Idea | Owns its own state; keeps only the unfinished token | Expat's processor loop (prolog → content → epilog) |
| Covers | Start/end/empty tags, quoted attributes, text, mismatched end tag, suspend hooks | Same, plus XML-declaration-like prolog |
| Missing | Comments, CDATA, DTD, entities, namespaces, encodings, external entities, DLL connection | Same |
| Used by the DLL | ❌ No | ❌ No |

Both are **separate parsers** next to `src/xp_parser.e` (8,795 lines), which holds all the W3C fixes. That's why finishing them (approach A) is so large.

## 6. ⚠️ Known limits and unverified points

- The 58 s / 5 ms figure is one measurement on the student PC (F05-1). Step 2 will repeat it properly.
- Whether B can save **all** the parser state is **not verified** yet (step 3).
- The time estimates are guesses.

Related: #197 (test 2 on several cores), #165 (callbacks across `XML_Parse` calls), PR #167 (profile work).
