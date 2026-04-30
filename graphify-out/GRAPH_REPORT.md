# Graph Report - SilverWorker  (2026-05-01)

## Corpus Check
- 54 files · ~56,642 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 218 nodes · 237 edges · 16 communities detected
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
1. `package:flutter/material.dart` - 15 edges
2. `package:flutter_riverpod/flutter_riverpod.dart` - 10 edges
3. `main()` - 7 edges
4. `generate_one()` - 5 edges
5. `package:go_router/go_router.dart` - 5 edges
6. `../providers/auth_provider.dart` - 5 edges
7. `package:cloud_firestore/cloud_firestore.dart` - 5 edges
8. `latest_meaningful_md()` - 4 edges
9. `load_docs()` - 4 edges
10. `GeneratedPluginRegistrant` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.` --rationale_for--> `handle_new_rx_page()`  [EXTRACTED]
  ios/Flutter/ephemeral/flutter_lldb_helper.py → SilverWorkerNow/ios/Flutter/ephemeral/flutter_lldb_helper.py

## Communities

### Community 0 - "Community 0"
Cohesion: 0.08
Nodes (28): ../../constants/address_data.dart, ../../constants/app_colors.dart, ../../constants/app_text_styles.dart, build, dispose, PhoneInputScreen, _PhoneInputScreenState, Scaffold (+20 more)

### Community 1 - "Community 1"
Cohesion: 0.06
Nodes (22): ApplicationFormScreen, build, Scaffold, build, JobDetailScreen, Scaffold, build, JobListScreen (+14 more)

### Community 2 - "Community 2"
Cohesion: 0.09
Nodes (18): ApplicationRepository, AuthRepository, Function, _mapAuthError, BookmarkRepository, ApplicationRepository, AuthRepository, Function (+10 more)

### Community 3 - "Community 3"
Cohesion: 0.13
Nodes (14): build, dispose, _distributeDigits, initState, _onDigitChanged, _onKeyEvent, OtpInputScreen, _OtpInputScreenState (+6 more)

### Community 4 - "Community 4"
Cohesion: 0.14
Nodes (10): ApplicationModel, copyWith, copyWith, JobModel, Address, copyWith, UserModel, BookmarkModel (+2 more)

### Community 5 - "Community 5"
Cohesion: 0.15
Nodes (12): dart:async, _AuthRefresh, dispose, GoRouter, MainScreen, OtpInputScreen, PhoneInputScreen, ProfileSetupScreen (+4 more)

### Community 6 - "Community 6"
Cohesion: 0.26
Nodes (11): block(), extract_working_dir(), is_direct_master_push(), is_repo_root(), is_write_git_command(), main(), Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push, working_dir가 프로젝트 루트인지 확인. (+3 more)

### Community 7 - "Community 7"
Cohesion: 0.18
Nodes (9): firebase_options.dart, DefaultFirebaseOptions, UnsupportedError, build, main, MaterialApp, MyApp, package:firebase_core/firebase_core.dart (+1 more)

### Community 8 - "Community 8"
Cohesion: 0.2
Nodes (7): main, main, main, package:flutter_test/flutter_test.dart, package:silver_worker_now/constants/address_data.dart, package:silver_worker_now/models/job_model.dart, package:silver_worker_now/models/user_model.dart

### Community 9 - "Community 9"
Cohesion: 0.46
Nodes (7): generate_all(), generate_one(), main(), _random_date_in_future(), _random_employment_type(), _random_salary(), upload_to_firestore()

### Community 10 - "Community 10"
Cohesion: 0.48
Nodes (6): latest_meaningful_md(), load_docs(), main(), Claude Code SessionStart / SubagentStart hook - injects General folder context., Return the most recent .md that isn't an empty session-summary., read_file()

### Community 11 - "Community 11"
Cohesion: 0.33
Nodes (5): JobRepository, JobRepository, ../models/job_filter.dart, ../models/job_model.dart, ../repositories/job_repository.dart

### Community 12 - "Community 12"
Cohesion: 0.4
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

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
- **118 isolated node(s):** `Claude Code SessionStart / SubagentStart hook - injects General folder context.`, `Return the most recent .md that isn't an empty session-summary.`, `Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push`, `working_dir가 프로젝트 루트인지 확인.`, `git push origin master/main 형태의 직접 푸시 감지.` (+113 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 12`** (5 nodes): `GeneratedPluginRegistrant`, `.registerWith()`, `-registerWithRegistry`, `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant.m`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 13`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 14`** (3 nodes): `hook_agent_notify.py`, `main()`, `Claude Code PostToolUse hook - Discord notification on agent completion. Called`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 15`** (3 nodes): `job_filter.dart`, `copyWith`, `JobFilter`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 1` to `Community 0`, `Community 3`, `Community 5`, `Community 7`?**
  _High betweenness centrality (0.174) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 2` to `Community 0`, `Community 3`, `Community 5`, `Community 7`, `Community 11`?**
  _High betweenness centrality (0.143) - this node is a cross-community bridge._
- **Why does `package:firebase_auth/firebase_auth.dart` connect `Community 2` to `Community 5`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **What connects `Claude Code SessionStart / SubagentStart hook - injects General folder context.`, `Return the most recent .md that isn't an empty session-summary.`, `Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push` to the rest of the system?**
  _118 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.09 - nodes in this community are weakly interconnected._