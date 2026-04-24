# KNOWLEDGE BASE — lib/core/

**Domain:** Core business logic + design tokens

## OVERVIEW
TimelineEngine (static methods), design system tokens (colors, typography, spacing, shadows, radius), and utility functions.

## STRUCTURE
```
core/
├── timeline_engine.dart      # Push-back / Compression algorithms (static only)
├── app_colors.dart           # Design token: color palette
├── app_typography.dart       # Design token: text styles
├── app_spacing.dart          # Design token: spacing values
├── app_shadows.dart          # Design token: shadow definitions
├── app_radius.dart           # Design token: border radius values
├── app_animations.dart       # Animation durations/curves
├── ad_utils.dart             # AdMob utility functions
└── l10n_utils.dart           # Localization helpers
```

## CONVENTIONS
- **TimelineEngine**: Static methods only — no instance state, no constructors
- **Design tokens**: `app_` prefix, exported as constants/classes
- **No business logic** outside timeline_engine.dart

## ANTI-PATTERNS
- **NEVER** add instance state to TimelineEngine — it's stateless
- **NEVER** mix design tokens with widget code — keep tokens centralized
- **NEVER** import from `views/` or `services/` — core is leaf-level dependency
