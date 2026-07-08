# Syntactic Analysis Comparison Report

**Generated:** 2026-07-08 00:46

**Sentence:** τῇ βασιλέως θυγατρὶ ἐδήλου ὁ ποιητὴς τὰ ποιήματα τὰ περὶ τῆς φύσεως γεγραμμένα .

**Analysis 1:** Editor_One  
urn:cite2:analyzer:analysis:2025-06-13-b0a12db9-bb69-471b-b75d-1931593a3b0c

**Analysis 2:** Editor_Two  
urn:cite2:analyzer:analysis:2025-06-13-b0a12db9-bb69-471b-b75d-1931593a3b0c

---

## Scores

| Metric | Value |
|--------|-------:|
| UAS    | 100.0% |
| LAS    | 100.0% |
| Tokens | 13 |

**UAS (Unlabeled Attachment Score)**: Measures how often the two analyses agree on the *head* (governor) of each token, regardless of the grammatical label.

**LAS (Labeled Attachment Score)**: Measures how often the two analyses agree on *both* the head *and* the grammatical label (relation) of each token.

## Differences

### Verbal Unit Comparison

- **Analysis 1**: 2 verbal units
- **Analysis 2**: 2 verbal units
- **Matched** (by token overlap): 2
- **Only in Analysis 1**: 0
- **Only in Analysis 2**: 0

**Jaccard similarity** is used to match verbal units across analyses. It measures the overlap between the sets of tokens belonging to each verbal unit (1.0 = identical token sets, 0.0 = no overlap). A threshold of 0.65 is used by default.

#### Matched Verbal Units

| VU1 | VU2 | Jaccard | Level | Syntactic Type                  | Semantic Type          |
|-----|-----|---------|-------|---------------------------------|------------------------|
| VU1 | VU1 | 1.0 | 1 | Independent Clause vs Independent Clause | Transitive vs Transitive |
| VU2 | VU3 | 0.714 | 2 vs 1 | Attributive Participle vs Circumstantial Participle | Intransitive vs Transitive |

### Token-by-Token Verbal Unit Assignment

Only tokens with **different** verbal unit assignments are shown below.

- **τὰ**
  - Analysis 1: Primary = VU1, All = VU1, VU2
  - Analysis 2: Primary = VU1, All = VU1

- **ποιήματα**
  - Analysis 1: Primary = VU1, All = VU1, VU2
  - Analysis 2: Primary = VU1, All = VU1

- **τὰ**
  - Analysis 1: Primary = VU1, All = VU1, VU2
  - Analysis 2: Primary = VU1, All = VU1, VU3

- **περὶ**
  - Analysis 1: Primary = VU1, All = VU1, VU2
  - Analysis 2: Primary = VU1, All = VU1, VU3

- **τῆς**
  - Analysis 1: Primary = VU1, All = VU1, VU2
  - Analysis 2: Primary = VU1, All = VU1, VU3

- **φύσεως**
  - Analysis 1: Primary = VU1, All = VU1, VU2
  - Analysis 2: Primary = VU1, All = VU1, VU3

- **γεγραμμένα**
  - Analysis 1: Primary = VU1, All = VU1, VU2
  - Analysis 2: Primary = VU1, All = VU1, VU3

---

## Tree Views

### Analysis 1 – Editor_One

```text
Syntax Tree — τῇ βασιλέως θυγατρὶ ἐδήλου ὁ ποιητὴς τὰ ποιήματα τὰ περὶ τῆς φύσεως γεγραμμένα .
======================================================================
ROOT (root)
  └── Unit Verb ←   ἐδήλου (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.4) [VU1]
    └── Subject ←     ποιητὴς (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.6) [VU1]
      └── Article ←       ὁ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.5) [VU1]
    └── Obj. of Verb ←     ποιήματα (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.8) [primary=VU1]
      └── Article ←       τὰ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.7) [primary=VU1]
      └── Adjectival ←       τὰ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.9) [primary=VU1]
        └── Unit Part. ←         γεγραμμένα (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.13) [primary=VU1]
          └── Preposition ←           περὶ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.10) [primary=VU1]
            └── Obj. of Prep. ←             φύσεως (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.12) [primary=VU1]
              └── Article ←               τῆς (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.11) [primary=VU1]
    └── Adverbial ←     θυγατρὶ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.3) [VU1]
      └── Article ←       τῇ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.1) [VU1]
      └── Adjectival ←       βασιλέως (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.2) [VU1]
```

### Analysis 2 – Editor_Two

```text
Syntax Tree — τῇ βασιλέως θυγατρὶ ἐδήλου ὁ ποιητὴς τὰ ποιήματα τὰ περὶ τῆς φύσεως γεγραμμένα .
======================================================================
ROOT (root)
  └── Unit Verb ←   ἐδήλου (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.4) [VU1]
    └── Subject ←     ποιητὴς (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.6) [VU1]
      └── Article ←       ὁ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.5) [VU1]
    └── Obj. of Verb ←     ποιήματα (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.8) [VU1]
      └── Article ←       τὰ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.7) [VU1]
      └── Adjectival ←       τὰ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.9) [primary=VU1]
        └── Unit Part. ←         γεγραμμένα (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.13) [primary=VU1]
          └── Preposition ←           περὶ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.10) [primary=VU1]
            └── Obj. of Prep. ←             φύσεως (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.12) [primary=VU1]
              └── Article ←               τῆς (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.11) [primary=VU1]
    └── Adverbial ←     θυγατρὶ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.3) [VU1]
      └── Article ←       τῇ (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.1) [VU1]
      └── Adjectival ←       βασιλέως (urn:cts:fuTeaching:blackwell.hq.2026:10.2.token.2) [VU1]
```

---
*Generated with SyntactileViz*
