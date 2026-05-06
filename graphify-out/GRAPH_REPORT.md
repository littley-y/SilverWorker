# Graph Report - SilverWorker  (2026-05-06)

## Corpus Check
- 69 files · ~82,136 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 382 nodes · 483 edges · 20 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
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
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 28 edges
2. `package:flutter_riverpod/flutter_riverpod.dart` - 22 edges
3. `../constants/app_colors.dart` - 13 edges
4. `../constants/app_text_styles.dart` - 13 edges
5. `package:flutter_test/flutter_test.dart` - 12 edges
6. `package:go_router/go_router.dart` - 10 edges
7. `main()` - 7 edges
8. `../providers/auth_provider.dart` - 7 edges
9. `package:firebase_auth/firebase_auth.dart` - 7 edges
10. `package:silver_worker_now/models/job_model.dart` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.` --rationale_for--> `handle_new_rx_page()`  [EXTRACTED]
  ios/Flutter/ephemeral/flutter_lldb_helper.py → SilverWorkerNow/ios/Flutter/ephemeral/flutter_lldb_helper.py
- `send_notification()` --calls--> `DiscordNotifier`  [INFERRED]
  tools/notify.py → tools/common/discord_notifier.py

## Communities

### Community 0 - "Community 0"
Cohesion: 0.04
Nodes (52): BookmarkRepository, main, main, main, main, _MockRepository, _sampleJob, _ErrorApplicationRepository (+44 more)

### Community 1 - "Community 1"
Cohesion: 0.07
Nodes (26): ../constants/app_colors.dart, ../constants/app_text_styles.dart, ApplicationResultScreen, build, Center, Icon, Scaffold, SizedBox (+18 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (25): firebase_options.dart, build, main, MyApp, AlertDialog, build, Container, Divider (+17 more)

### Community 3 - "Community 3"
Cohesion: 0.08
Nodes (25): ../../constants/address_data.dart, build, dispose, PhoneInputScreen, _PhoneInputScreenState, Scaffold, SizedBox, Spacer (+17 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (24): ApplicationRepository, ApplicationFormScreen, _ApplicationFormScreenState, build, Center, Column, dispose, initState (+16 more)

### Community 5 - "Community 5"
Cohesion: 0.09
Nodes (22): JobRepository, JobRepository, build, Card, Center, Divider, _EmptyState, _ErrorState (+14 more)

### Community 6 - "Community 6"
Cohesion: 0.09
Nodes (18): app_colors.dart, build, Card, Container, _EmploymentTypeChip, _formatDeadline, _IntensityBadge, JobCard (+10 more)

### Community 7 - "Community 7"
Cohesion: 0.09
Nodes (22): dart:async, ApplicationFormScreen, ApplicationListScreen, ApplicationResultScreen, _AuthRefresh, dispose, GoRouter, JobDetailScreen (+14 more)

### Community 8 - "Community 8"
Cohesion: 0.11
Nodes (15): AuthRepository, Function, _mapAuthError, AlreadyAppliedException, ApplicationRepository, JobClosedException, JobNotFoundException, AuthRepository (+7 more)

### Community 9 - "Community 9"
Cohesion: 0.12
Nodes (16): build, Center, Column, _ConditionRow, Divider, _HeaderSection, Icon, _JobDetailBody (+8 more)

### Community 10 - "Community 10"
Cohesion: 0.13
Nodes (14): build, dispose, _distributeDigits, initState, _onDigitChanged, _onKeyEvent, OtpInputScreen, _OtpInputScreenState (+6 more)

### Community 11 - "Community 11"
Cohesion: 0.13
Nodes (11): ApplicationModel, copyWith, copyWith, JobModel, Address, copyWith, UserModel, BookmarkModel (+3 more)

### Community 12 - "Community 12"
Cohesion: 0.26
Nodes (11): block(), extract_working_dir(), is_direct_master_push(), is_repo_root(), is_write_git_command(), main(), Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push, working_dir가 프로젝트 루트인지 확인. (+3 more)

### Community 13 - "Community 13"
Cohesion: 0.46
Nodes (7): generate_all(), generate_one(), main(), _random_date_in_future(), _random_employment_type(), _random_salary(), upload_to_firestore()

### Community 14 - "Community 14"
Cohesion: 0.38
Nodes (2): DiscordNotifier, send_notification()

### Community 15 - "Community 15"
Cohesion: 0.48
Nodes (6): latest_meaningful_md(), load_docs(), main(), Claude Code SessionStart / SubagentStart hook - injects General folder context., Return the most recent .md that isn't an empty session-summary., read_file()

### Community 16 - "Community 16"
Cohesion: 0.4
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 17 - "Community 17"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 18 - "Community 18"
Cohesion: 0.67
Nodes (1): Claude Code PostToolUse hook - Discord notification on agent completion. Called

### Community 19 - "Community 19"
Cohesion: 0.67
Nodes (2): copyWith, JobFilter

## Knowledge Gaps
- **251 isolated node(s):** `Claude Code SessionStart / SubagentStart hook - injects General folder context.`, `Return the most recent .md that isn't an empty session-summary.`, `Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push`, `working_dir가 프로젝트 루트인지 확인.`, `git push origin master/main 형태의 직접 푸시 감지.` (+246 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 14`** (7 nodes): `DiscordNotifier`, `.__init__()`, `.send()`, `._send_webhook()`, `send_notification()`, `discord_notifier.py`, `notify.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 16`** (5 nodes): `GeneratedPluginRegistrant`, `.registerWith()`, `-registerWithRegistry`, `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant.m`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 17`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 18`** (3 nodes): `hook_agent_notify.py`, `main()`, `Claude Code PostToolUse hook - Discord notification on agent completion. Called`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 19`** (3 nodes): `copyWith`, `JobFilter`, `job_filter.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 6` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 9`, `Community 10`?**
  _High betweenness centrality (0.244) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 0` to `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 10`?**
  _High betweenness centrality (0.161) - this node is a cross-community bridge._
- **Why does `package:firebase_auth/firebase_auth.dart` connect `Community 8` to `Community 0`, `Community 2`, `Community 7`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **What connects `Claude Code SessionStart / SubagentStart hook - injects General folder context.`, `Return the most recent .md that isn't an empty session-summary.`, `Claude Code PreToolUse hook - guards git write operations.  Rules:   1. git push` to the rest of the system?**
  _251 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._