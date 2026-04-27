# Graph Report - SilverWorkerNow  (2026-04-27)

## Corpus Check
- 39 files · ~7,274 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 117 nodes · 106 edges · 15 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 12 edges
2. `package:flutter_riverpod/flutter_riverpod.dart` - 5 edges
3. `GeneratedPluginRegistrant` - 4 edges
4. `package:cloud_firestore/cloud_firestore.dart` - 4 edges
5. `../utils/timestamp_helper.dart` - 4 edges
6. `package:firebase_core/firebase_core.dart` - 2 edges
7. `../models/job_model.dart` - 2 edges
8. `../models/job_filter.dart` - 2 edges
9. `../models/user_model.dart` - 2 edges
10. `../models/bookmark_model.dart` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities

### Community 0 - "Community 0"
Cohesion: 0.13
Nodes (10): build, LoginScreen, Scaffold, build, ProfileRegisterScreen, Scaffold, build, JobListScreen (+2 more)

### Community 1 - "Community 1"
Cohesion: 0.14
Nodes (10): ApplicationRepository, BookmarkRepository, ApplicationRepository, BookmarkRepository, ../models/application_model.dart, ../models/bookmark_model.dart, package:cloud_firestore/cloud_firestore.dart, package:flutter_riverpod/flutter_riverpod.dart (+2 more)

### Community 2 - "Community 2"
Cohesion: 0.14
Nodes (10): ApplicationModel, copyWith, BookmarkModel, copyWith, copyWith, JobModel, Address, copyWith (+2 more)

### Community 3 - "Community 3"
Cohesion: 0.18
Nodes (9): firebase_options.dart, DefaultFirebaseOptions, UnsupportedError, build, main, MaterialApp, MyApp, package:firebase_core/firebase_core.dart (+1 more)

### Community 4 - "Community 4"
Cohesion: 0.29
Nodes (5): AuthRepository, AuthRepository, ../models/user_model.dart, package:firebase_auth/firebase_auth.dart, ../repositories/auth_repository.dart

### Community 5 - "Community 5"
Cohesion: 0.33
Nodes (5): JobRepository, JobRepository, ../models/job_filter.dart, ../models/job_model.dart, ../repositories/job_repository.dart

### Community 6 - "Community 6"
Cohesion: 0.4
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 7 - "Community 7"
Cohesion: 0.5
Nodes (3): build, JobDetailScreen, Scaffold

### Community 8 - "Community 8"
Cohesion: 0.5
Nodes (3): build, MyPageScreen, Scaffold

### Community 9 - "Community 9"
Cohesion: 0.5
Nodes (3): ApplicationFormScreen, build, Scaffold

### Community 10 - "Community 10"
Cohesion: 0.5
Nodes (3): build, LoadingOverlay, Stack

### Community 11 - "Community 11"
Cohesion: 0.5
Nodes (3): BadgeWidget, build, Container

### Community 12 - "Community 12"
Cohesion: 0.5
Nodes (3): build, Card, JobCard

### Community 13 - "Community 13"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 14 - "Community 14"
Cohesion: 0.67
Nodes (2): copyWith, JobFilter

## Knowledge Gaps
- **61 isolated node(s):** `MyApp`, `main`, `build`, `MaterialApp`, `firebase_options.dart` (+56 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 6`** (5 nodes): `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant`, `.registerWith()`, `-registerWithRegistry`, `GeneratedPluginRegistrant.m`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 13`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 14`** (3 nodes): `copyWith`, `JobFilter`, `job_filter.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 0` to `Community 3`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`?**
  _High betweenness centrality (0.325) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 1` to `Community 3`, `Community 4`, `Community 5`?**
  _High betweenness centrality (0.243) - this node is a cross-community bridge._
- **What connects `MyApp`, `main`, `build` to the rest of the system?**
  _61 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._