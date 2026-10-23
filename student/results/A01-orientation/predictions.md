# A01 change-and-predict: predictions (written before the run)

> **Written:** 2026-10-22, before any of these inputs was run · **Issue:** [#68](https://github.com/andersoxie/xpact/issues/68)
> · **Base:** `student-Mass` @ `76ac272`
>
> This file is committed **on its own, before** the run, so `git log` shows
> that the predictions came first. It is not edited after the run; the actual
> results and the comparison are in [README.md](README.md).
>
> Predictions written by Claude Code at the student's request, from the XML
> 1.0 rules and the `src/xp_parser.e` source, not from running the inputs.

Each input is [`ok.xml`](../../baseline/walkthrough/ok.xml) with **one** small change:

```
ok.xml:  <root><child id="1">text</child><empty /></root>     ACCEPT, 7 events
```

## 1. Duplicate attribute: [`change-1-duplicate-attribute.xml`](inputs/change-1-duplicate-attribute.xml)

```
<root><child id="1" id="2">text</child><empty /></root>
```

| | Prediction | Why |
|---|---|---|
| Result | **REJECT** | XML 1.0 well-formedness constraint "Unique Att Spec": an attribute name may appear only once in a tag |
| Error | `duplicate attribute` | the message set in `XP_PARSER` (`src/xp_parser.e`, lines 988 and 1179) |
| Events before the error | **1** (`start-element root`) | `child`'s start tag is invalid, so its start event is not delivered |
| Position | line 1; column not predicted | |

## 2. Predefined entity in text: [`change-2-entity.xml`](inputs/change-2-entity.xml)

```
<root><child id="1">a &amp; b</child><empty /></root>
```

| | Prediction | Why |
|---|---|---|
| Result | **ACCEPT** | `&amp;` is one of the five predefined entities |
| Text delivered | `a & b` (the entity replaced by `&`) | |
| Text events | **3**: `"a "`, `"&"`, `" b"` | Expat delivers character data in pieces and splits at entity references; xpact copies Expat's callbacks |
| Events in total | **9** (7 of `ok.xml` + 2 extra text pieces) | |

Confidence: medium for the split into 3 pieces; high for ACCEPT.

## 3. Root end tag missing: [`change-3-no-root-end.xml`](inputs/change-3-no-root-end.xml)

```
<root><child id="1">text</child><empty />
```

| | Prediction | Why |
|---|---|---|
| Result | **REJECT** | the document ends while `root` is still open |
| Error | an "end of input" kind of error (exact text not predicted) | |
| Events before the error | **6** (everything except `end-element root`) | all of the document before the end is well-formed |
| Position | at the end of the input (line 1) | |
