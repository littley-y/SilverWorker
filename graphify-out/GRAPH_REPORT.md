# Graph Report - SilverWorker  (2026-04-28)

## Corpus Check
- 46 files · ~37,031 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 145 nodes · 137 edges · 16 communities detected
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
- [[_COMMUNITY_Community 15|Community 15]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 12 edges
2. `main()` - 7 edges
3. `package:flutter_riverpod/flutter_riverpod.dart` - 5 edges
4. `latest_meaningful_md()` - 4 edges
5. `load_docs()` - 4 edges
6. `GeneratedPluginRegistrant` - 4 edges
7. `package:cloud_firestore/cloud_firestore.dart` - 4 edges
8. `../utils/timestamp_helper.dart` - 4 edges
9. `read_file()` - 3 edges
10. `is_repo_root()` - 3 edges

## Surprising Connections (you probably didn't know these)
- `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.` --rationale_for--> `handle_new_rx_page()`  [EXTRACTED]
  ios/Flutter/ephemeral/flutter_lldb_helper.py → SilverWorkerNow/ios/Flutter/ephemeral/flutter_lldb_helper.py

## Communities

### Community 0 - "Community 0"
Cohesion: 0.1
Nodes (15): ApplicationRepository, AuthRepository, BookmarkRepository, ApplicationRepository, AuthRepository, BookmarkRepository, ../models/application_model.dart, ../models/bookmark_model.dart (+7 more)

### Community 1 - "Community 1"
Cohesion: 0.11
Nodes (13): ApplicationFormScreen, build, Scaffold, build, MyPageScreen, Scaffold, BadgeWidget, build (+5 more)

### Community 2 - "Community 2"
Cohesion: 0.14
Nodes (10): ApplicationModel, copyWith, BookmarkModel, copyWith, copyWith, JobModel, Address, copyWith (+2 more)

### Community 3 - "Community 3"
Cohesion: 0.26
Nodes (11): block(), extract_working_dir(), is_direct_master_push(), is_repo_root(), is_write_git_command(), main(), Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push, working_dir가 프로젝트 루트인지 확인. (+3 more)

### Community 4 - "Community 4"
Cohesion: 0.18
Nodes (9): firebase_options.dart, DefaultFirebaseOptions, UnsupportedError, build, main, MaterialApp, MyApp, package:firebase_core/firebase_core.dart (+1 more)

### Community 5 - "Community 5"
Cohesion: 0.48
Nodes (6): latest_meaningful_md(), load_docs(), main(), Claude Code SessionStart / SubagentStart hook - injects General folder context., Return the most recent .md that isn't an empty session-summary., read_file()

### Community 6 - "Community 6"
Cohesion: 0.33
Nodes (5): JobRepository, JobRepository, ../models/job_filter.dart, ../models/job_model.dart, ../repositories/job_repository.dart

### Community 7 - "Community 7"
Cohesion: 0.4
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 8 - "Community 8"
Cohesion: 0.5
Nodes (3): build, JobListScreen, Scaffold

### Community 9 - "Community 9"
Cohesion: 0.5
Nodes (3): build, JobDetailScreen, Scaffold

### Community 10 - "Community 10"
Cohesion: 0.5
Nodes (3): build, LoginScreen, Scaffold

### Community 11 - "Community 11"
Cohesion: 0.5
Nodes (3): build, ProfileRegisterScreen, Scaffold

### Community 12 - "Community 12"
Cohesion: 0.5
Nodes (3): build, LoadingOverlay, Stack

### Community 13 - "Community 13"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 14 - "Community 14"
Cohesion: 0.67
Nodes (1): Claude Code PostToolUse hook - Discord notification on agent completion. Called

### Community 15 - "Community 15"
Cohesion: 0.67
Nodes (2): copyWith, JobFilter

## Knowledge Gaps
- **68 isolated node(s):** `Claude Code SessionStart / SubagentStart hook - injects General folder context.`, `Return the most recent .md that isn't an empty session-summary.`, `Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push`, `working_dir가 프로젝트 루트인지 확인.`, `git push origin master/main 형태의 직접 푸시 감지.` (+63 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 7`** (5 nodes): `GeneratedPluginRegistrant`, `.registerWith()`, `-registerWithRegistry`, `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant.m`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 13`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 14`** (3 nodes): `hook_agent_notify.py`, `main()`, `Claude Code PostToolUse hook - Discord notification on agent completion. Called`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 15`** (3 nodes): `job_filter.dart`, `copyWith`, `JobFilter`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 1` to `Community 4`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`?**
  _High betweenness centrality (0.211) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 0` to `Community 4`, `Community 6`?**
  _High betweenness centrality (0.157) - this node is a cross-community bridge._
- **What connects `Claude Code SessionStart / SubagentStart hook - injects General folder context.`, `Return the most recent .md that isn't an empty session-summary.`, `Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push` to the rest of the system?**
  _68 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._