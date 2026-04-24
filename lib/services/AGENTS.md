# KNOWLEDGE BASE — lib/services/

**Domain:** Database layer + alarm scheduling

## OVERVIEW
Interface-based database pattern + alarm scheduler. All data access goes through `DatabaseInterface`.

## STRUCTURE
```
services/
├── database_interface.dart     # Abstract interface for DB operations
├── database_service_impl.dart  # Real implementation (SQLite/Hive)
├── mock_database_service.dart  # Test double for unit tests
├── database_helper.dart        # DB initialization/migration helpers
└── alarm_scheduler_service.dart # Alarm scheduling logic
```

## CONVENTIONS
- **Interface pattern**: `DatabaseInterface` → `DatabaseServiceImpl` + `MockDatabaseService`
- **All DB access**: Through interface — never direct DB calls in views/providers
- **Mock service**: Used in tests — matches interface exactly

## ANTI-PATTERNS
- **NEVER** bypass `DatabaseInterface` for direct DB calls
- **NEVER** add UI logic to services — keep data access pure
- **NEVER** forget to update `MockDatabaseService` when adding interface methods
