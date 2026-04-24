# KNOWLEDGE BASE — lib/views/

**Domain:** UI screens, widgets, and visual components

## OVERVIEW
5 screens + reusable widgets with Glassmorphism design language (Apple HIG + glass effect).

## STRUCTURE
```
views/
├── main_screen.dart                    # Primary screen with timeline
├── splash_screen.dart                  # App launch screen
├── active_preparation_screen.dart      # Active prep view
├── preset_selection_screen.dart        # Routine preset picker
├── result_briefing_screen.dart         # Result summary screen
└── widgets/
    ├── glass_container.dart            # Core glassmorphism widget
    ├── timeline_item_widget.dart       # Timeline block renderer
    ├── timeline_shift_widget.dart      # Timeline shift visualizer
    ├── alarm_status_card.dart          # Alarm status display
    ├── time_and_day_card.dart          # Time/day selector
    ├── slidable_routine_item.dart      # Swipeable routine item
    ├── summary_banner.dart             # Result summary banner
    ├── banner_ad_widget.dart           # AdMob banner ad
    ├── native_ad_card.dart             # AdMob native ad
    └── dialogs/
        └── main_screen_dialogs.dart    # Dialog components
```

## CONVENTIONS
- **Screen files**: `*_screen.dart` naming convention
- **Widgets**: Flat directory under `widgets/` (except `dialogs/`)
- **GlassContainer**: Reusable glassmorphism wrapper — use instead of Container for cards
- **Ad widgets**: `banner_ad_widget.dart`, `native_ad_card.dart` — check ad_config.dart for conditions

## ANTI-PATTERNS
- **NEVER** put business logic in screens — delegate to providers/services
- **NEVER** hardcode colors/typography — use `app_colors.dart` / `app_typography.dart`
- **NEVER** create nested widget directories beyond `dialogs/`
