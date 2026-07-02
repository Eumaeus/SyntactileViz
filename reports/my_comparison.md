# Syntactic Analysis Comparison Report

**Generated:** 2026-07-02 00:01

**Sentence:** θυσίαν ἀγάγωμεν θεοῖς τοῖς Ἀθηναίους ἐν ἐκείνῃ τῇ μάχῃ σώσασιν ὅπως καὶ νῦν ἐθέλωσι πάντες οἱ θεοὶ τὴν δημοκρατίαν φυλάττειν .

**Analysis 1:** Christopher_Blackwell  
urn:cite2:analyzer:analysis:2025-06-13-71b14619-0261-4ee0-90ae-00a9ecd76cef

**Analysis 2:** Able_Student  
urn:cite2:analyzer:analysis:2025-06-13-71b14619-0261-4ee0-90ae-00a9ecd76cef

---

## Scores

| Metric | Value |
|--------|-------:|
| UAS    | 90.0% |
| LAS    | 90.0% |
| Tokens | 20 |

## Differences

### Major Differences (different head)

- **θεοῖς**: head `"ἀγάγωμεν"` vs `"θυσίαν"`
- **καὶ**: head `"νῦν"` vs `"ἐθέλωσι"`

### Verbal Unit Comparison

- **VUs in Analysis 1**: 3
- **VUs in Analysis 2**: 3

---

## Tree Views

### Analysis 1 – Christopher_Blackwell

```text
Syntax Tree — θυσίαν ἀγάγωμεν θεοῖς τοῖς Ἀθηναίους ἐν ἐκείνῃ τῇ μάχῃ σώσασιν ὅπως καὶ νῦν ἐθέλωσι πάντες οἱ θεοὶ τὴν δημοκρατίαν φυλάττειν .
======================================================================
ROOT (root)
  └── Unit Verb ←   ἀγάγωμεν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.2) [VU1]
    └── Direct Object ←     θυσίαν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.1) [VU1]
    └── Adverbial ←     θεοῖς (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.3) [primary=VU1]
      └── Article ←       τοῖς (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.4) [primary=VU1]
        └── Unit Participle ←         σώσασιν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.10) [primary=VU1]
          └── Direct Object ←           Ἀθηναίους (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.5) [primary=VU1]
          └── Preposition ←           ἐν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.6) [primary=VU1]
            └── Object of Prep. ←             μάχῃ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.9) [primary=VU1]
              └── Article ←               τῇ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.8) [primary=VU1]
              └── Attribute ←               ἐκείνῃ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.7) [primary=VU1]
    └── Unit Adverbial ←     ὅπως (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.11) [VU3]
      └── Unit Verb ←       ἐθέλωσι (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.14) [VU3]
        └── Adverbial ←         νῦν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.13) [VU3]
          └── Adverbial ←           καὶ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.12) [VU3]
        └── Subject ←         θεοὶ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.17) [VU3]
          └── Attribute ←           πάντες (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.15) [VU3]
          └── Article ←           οἱ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.16) [VU3]
        └── Auxiliary Infinitive ←         φυλάττειν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.20) [VU3]
          └── Direct Object ←           δημοκρατίαν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.19) [VU3]
            └── Article ←             τὴν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.18) [VU3]
```

### Analysis 2 – Able_Student

```text
Syntax Tree — θυσίαν ἀγάγωμεν θεοῖς τοῖς Ἀθηναίους ἐν ἐκείνῃ τῇ μάχῃ σώσασιν ὅπως καὶ νῦν ἐθέλωσι πάντες οἱ θεοὶ τὴν δημοκρατίαν φυλάττειν .
======================================================================
ROOT (root)
  └── Unit Verb ←   ἀγάγωμεν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.2) [VU1]
    └── Direct Object ←     θυσίαν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.1) [VU1]
      └── Attribute ←       θεοῖς (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.3) [primary=VU1]
        └── Article ←         τοῖς (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.4) [primary=VU1]
          └── Unit Participle ←           σώσασιν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.10) [primary=VU1]
            └── Direct Object ←             Ἀθηναίους (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.5) [primary=VU1]
            └── Preposition ←             ἐν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.6) [primary=VU1]
              └── Object of Prep. ←               μάχῃ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.9) [primary=VU1]
                └── Article ←                 τῇ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.8) [primary=VU1]
                └── Attribute ←                 ἐκείνῃ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.7) [primary=VU1]
    └── Unit Adverbial ←     ὅπως (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.11) [VU3]
      └── Unit Verb ←       ἐθέλωσι (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.14) [VU3]
        └── Adverbial ←         καὶ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.12) [VU3]
        └── Adverbial ←         νῦν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.13) [VU3]
        └── Subject ←         θεοὶ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.17) [VU3]
          └── Attribute ←           πάντες (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.15) [VU3]
          └── Article ←           οἱ (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.16) [VU3]
        └── Auxiliary Infinitive ←         φυλάττειν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.20) [VU3]
          └── Direct Object ←           δημοκρατίαν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.19) [VU3]
            └── Article ←             τὴν (urn:cts:fuTeaching:blackwell.hq.2026:8.2.token.18) [VU3]
```

---
*Generated with SyntactileViz*
