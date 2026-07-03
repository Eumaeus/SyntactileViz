# Syntactic Analysis Comparison Report

**Generated:** 2026-07-02 21:59

**Sentence:** τὰ τῶν θεῶν δῶρα πέμπει ὁ τοῦ ἀνθρώπου ἀδελφὸς ἐκ τῆς οἰκίας εἰς τὰς νήσους .

**Analysis 1:** CWB  
urn:cite2:analyzer:analysis:2025-06-13-ae0e53d5-90b3-4efa-aece-1eedfa83c60c

**Analysis 2:** Bad_Student  
urn:cite2:analyzer:analysis:2025-06-13-ae0e53d5-90b3-4efa-aece-1eedfa83c60c

---

## Scores

| Metric | Value |
|--------|-------:|
| UAS    | 80.0% |
| LAS    | 66.7% |
| Tokens | 15 |

## Differences

### Minor Differences (same head, different label)

- **ἀδελφὸς**: `"Subject"` vs `"Direct Object"`
- **δῶρα**: `"Direct Object"` vs `"Subject"`

### Major Differences (different head)

- **οἰκίας**: head `"ἐκ"` vs `"εἰς"`
- **ἐκ**: head `"πέμπει"` vs `"δῶρα"`
- **νήσους**: head `"εἰς"` vs `"ἐκ"`

### Verbal Unit Comparison

- **VUs in Analysis 1**: 1
- **VUs in Analysis 2**: 1

---

## Tree Views

### Analysis 1 – CWB

```text
Syntax Tree — τὰ τῶν θεῶν δῶρα πέμπει ὁ τοῦ ἀνθρώπου ἀδελφὸς ἐκ τῆς οἰκίας εἰς τὰς νήσους .
======================================================================
ROOT (root)
  └── Unit Verb ←   πέμπει (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.5) [VU1]
    └── Subject ←     ἀδελφὸς (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.9) [VU1]
      └── Article ←       ὁ (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.6) [VU1]
      └── Attribute ←       ἀνθρώπου (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.8) [VU1]
        └── Article ←         τοῦ (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.7) [VU1]
    └── Direct Object ←     δῶρα (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.4) [VU1]
      └── Article ←       τὰ (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.1) [VU1]
      └── Attribute ←       θεῶν (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.3) [VU1]
        └── Article ←         τῶν (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.2) [VU1]
    └── Preposition ←     ἐκ (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.10) [VU1]
      └── Object of Prep. ←       οἰκίας (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.12) [VU1]
        └── Article ←         τῆς (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.11) [VU1]
    └── Preposition ←     εἰς (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.13) [VU1]
      └── Object of Prep. ←       νήσους (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.15) [VU1]
        └── Article ←         τὰς (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.14) [VU1]
```

### Analysis 2 – Bad_Student

```text
Syntax Tree — τὰ τῶν θεῶν δῶρα πέμπει ὁ τοῦ ἀνθρώπου ἀδελφὸς ἐκ τῆς οἰκίας εἰς τὰς νήσους .
======================================================================
ROOT (root)
  └── Unit Verb ←   πέμπει (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.5) [VU1]
    └── Direct Object ←     ἀδελφὸς (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.9) [VU1]
      └── Article ←       ὁ (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.6) [VU1]
      └── Attribute ←       ἀνθρώπου (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.8) [VU1]
        └── Article ←         τοῦ (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.7) [VU1]
    └── Subject ←     δῶρα (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.4) [VU1]
      └── Article ←       τὰ (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.1) [VU1]
      └── Attribute ←       θεῶν (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.3) [VU1]
        └── Article ←         τῶν (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.2) [VU1]
      └── Preposition ←       ἐκ (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.10) [VU1]
        └── Object of Prep. ←         νήσους (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.15) [VU1]
          └── Article ←           τὰς (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.14) [VU1]
    └── Preposition ←     εἰς (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.13) [VU1]
      └── Object of Prep. ←       οἰκίας (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.12) [VU1]
        └── Article ←         τῆς (urn:cts:fuTeaching:blackwell.hq.2026:1.10.token.11) [VU1]
```

---
*Generated with SyntactileViz*
