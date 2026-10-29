# Parser changes this week (23–28 October), in plain words

> From Masoud (CodTanium) · state: `student-Mass` @ [`e5d59e2`](https://github.com/andersoxie/xpact/commit/e5d59e2) on andersoxie/xpact · nothing pushed to `main`
> See also: [requests for 2026-10-29](2026-10-29.md)

Think of xpact as a **reader** of XML files. A program hands it a file, and the reader tells the program what is inside: "here is a tag, here is some text, here is a setting". This week I fixed places where the reader **crashed**, **misread** something, or was **too slow**.

## 1. Crashes and wrong answers (27 October, F1–F7)

Running all the W3C test files (Option A, #146/#151) showed small mistakes. Most were about XML files that include **other files**, like a book that says "see a chapter in another book".

| Fix | In plain words | Commit |
|---|---|---|
| F1 | A file that includes **itself** made the reader loop forever and crash; now it notices and stops | [`8beecc4`](https://github.com/andersoxie/xpact/commit/8beecc4) |
| F2 | `%name;` references inside the outside DTD are now read correctly | [`200389f`](https://github.com/andersoxie/xpact/commit/200389f) |
| F3 | Only the first top element in an outside file is counted | [`4d8e1fc`](https://github.com/andersoxie/xpact/commit/4d8e1fc) |
| F4 | Every entity must be declared in a "standalone" document | [`3b18f90`](https://github.com/andersoxie/xpact/commit/3b18f90) |
| F5 | The first line of an outside file must say its encoding | [`3ef6a7f`](https://github.com/andersoxie/xpact/commit/3ef6a7f) |
| F6 | An XML declaration in the wrong place is rejected | [`cd719ea`](https://github.com/andersoxie/xpact/commit/cd719ea) |
| F7 | The DLL tells the program where the main file is when an outside file is needed | [`915ab06`](https://github.com/andersoxie/xpact/commit/915ab06) |
| Speed (#148) | Entity references were very slow; the reader now remembers its position instead of searching from the start | [`e5cc8f7`](https://github.com/andersoxie/xpact/commit/e5cc8f7) |

The same day I merged your `main` (#150) into this work, and removed my own copies of things you had already fixed there (`ef50129`, `5e93e85`, `6e99419`).

## 2. Missing or messy information (28 October, #160–#164)

The reader said "yes, this file is OK", but **reported some of the content wrong**. Found by comparing with the W3C suite's expected output files.

| Fix | In plain words | PR |
|---|---|---|
| Defaults | A file can say "if this tag has no colour, use red"; the reader forgot to fill in "red" when that rule was in an outside DTD or file | [#160](https://github.com/andersoxie/xpact/pull/160) |
| Spaces in defaults | Values like `"  red  "` for token-type attributes are now cleaned to `"red"` | [#161](https://github.com/andersoxie/xpact/pull/161) |
| Spaces in public names | The same clean-up for public names in notation declarations | [#162](https://github.com/andersoxie/xpact/pull/162) |
| Invisible character | A second "byte order mark" character is kept as text instead of being thrown away | [#163](https://github.com/andersoxie/xpact/pull/163) |
| Copy, don't run | A `%name;` inside an entity value is pasted in as plain text, not treated as instructions | [#164](https://github.com/andersoxie/xpact/pull/164) |

**Result:** xpact now gives exactly the right content for **399 of the 432** W3C test files that have an expected answer, up from 359.

## 3. Your changes in the same week (24–27 October)

Mostly **speed** (less rescanning, cheaper text and attribute handling) and **DLL stability** (buffer, reset and error handling; parser handles kept alive until freed), better piece-by-piece parsing and DTD replay for Expat compatibility, and local external files for the W3C suite (#150).

## 4. Still waiting

- ⬜ A **Jenkins** run on `student-Mass` @ `e5d59e2`. The issues stay open until it has passed.
