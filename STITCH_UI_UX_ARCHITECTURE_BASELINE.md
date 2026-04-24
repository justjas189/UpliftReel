# Uplift Reel UI/UX Architecture Baseline (for Stitch)

## Baseline Scope for Stitch

- Active UI stack is the enhanced set in src/navigation/AppNavigation.tsx (imports and routes EnhancedHomeScreen, EnhancedMoodInputScreen, EnhancedPreferencesScreen), and this is what App entry loads via App.tsx.
- Legacy screens still exist in src/screens/HomeScreen.tsx, src/screens/MoodInputScreen.tsx, src/screens/PreferencesScreen.tsx, but should be treated as fallback/reference, not baseline.

## Core Layouts

- Daily Recommendation view hierarchy (active):
- SafeArea (commonStyles.safeArea)
- ScrollView with pull-to-refresh
- Animated header (title + Set Mood CTA)
- Optional notification banner
- Movie hero card (poster + title/meta + genre tags)
- Synopsis/details card
- Streaming availability card
- Rating card with stars
- Action section (Watch Trailer, View Details, Watched It, Skip, Share)
- Bottom spacer
- Source: src/screens/EnhancedHomeScreen.tsx

- Daily Recommendation reusable building blocks:
- Card, Button, Typography, RatingStars, MoviePoster from src/components/UIComponents.tsx
- Composed inside src/screens/EnhancedHomeScreen.tsx

- Mood/Emoji Selection hierarchy (active):
- SafeArea
- ScrollView
- Animated header
- Section card: mood grid (8 mood cards)
- Section card: energy selection row
- Section card: time-available options
- Submit section (primary CTA + ghost skip)
- Bottom spacer
- Source: src/screens/EnhancedMoodInputScreen.tsx

- Mood card anatomy (active):
- Icon + label + description + conditional genre preview chip + selected check indicator
- Selection state drives border/background emphasis and scale animation
- Source: src/screens/EnhancedMoodInputScreen.tsx

- Preferences layout hierarchy (active, for toggle behavior):
- Header
- Genre section card with chip grid
- Rating section card with single-select option list
- Conditional summary card
- Action buttons (save/reset)
- Tips card
- Source: src/screens/EnhancedPreferencesScreen.tsx

## Design Tokens

- Primary token source is src/styles/DesignSystem.ts (colors, spacing, borderRadius, typography, shadows, common styles).

- Core brand colors used repeatedly:
- primary #173B6C
- secondary #22A3F1
- accent #FF6A3D
- white #FFFFFF
- grays (gray100/200/600/700/900)
- Definitions: src/styles/DesignSystem.ts

- Surface pattern:
- App background uses background/surface neutrals
- Cards use white surfaces plus subtle elevation/shadow
- Sources: src/styles/DesignSystem.ts, src/components/UIComponents.tsx

- Typography scale pattern:
- xs 12, sm 14, base 16, lg 18, xl 20, 2xl 24, 3xl 30, 4xl 36
- Headings are bold/600
- Body is base/sm
- Repeated via Typography variants h1-h4/body1/body2/caption
- Sources: src/styles/DesignSystem.ts, src/components/UIComponents.tsx

- Spacing pattern:
- 4 / 8 / 16 / 20 / 24 / 32 / 40 / 48 / 64 scale
- Most layout blocks use 16 or 24
- 8 is used for inter-item gaps/chips
- 32 is used for loading/empty spacing
- Source: src/styles/DesignSystem.ts

- Border radius pattern:
- Small rounded controls: 10
- Standard controls: 16
- Cards: 18
- Larger cards: 22
- Pill chips: full (9999)
- Source: src/styles/DesignSystem.ts

- Button pattern:
- Semantic variants: primary / secondary / outline / ghost
- Size ladder with min-heights: 32 / 44 / 52 / 60
- Disabled state suppresses shadow and shifts to gray
- Source: src/components/UIComponents.tsx

- Token drift note:
- Multiple legacy screens define local DesignSystem objects instead of importing shared tokens
- gray100 varies between #F4F7FB and #F8F9FA
- Sources: src/screens/HomeScreen.tsx, src/screens/MoodInputScreen.tsx, src/screens/PreferencesScreen.tsx, src/styles/DesignSystem.ts

## Interactive UX (Mood Controls and Preference Toggles)

- Mood selection state model:
- selectedMood, selectedEnergy, selectedTime
- Source: src/screens/EnhancedMoodInputScreen.tsx

- Mood interaction response:
- Tapping a mood triggers handleMoodSelect with per-card Animated.sequence scale feedback
- Selected visual state is applied
- Genre preview appears only for selected mood
- Source: src/screens/EnhancedMoodInputScreen.tsx

- Mood submit gating:
- Primary CTA is disabled until a mood is selected
- On submit, payload includes mood + energy + time + timestamp
- updateCurrentMood is called
- Success alert is shown
- User is navigated back to Home
- Source: src/screens/EnhancedMoodInputScreen.tsx

- Preference toggle model:
- selectedGenres is multi-select (chip toggles add/remove)
- selectedRating is single-select
- Source: src/screens/EnhancedPreferencesScreen.tsx

- Preference save gating:
- Save is disabled when no genres are selected
- Successful submit calls updateUserPreferences with selectedGenres and mapped minRating
- Navigation returns to Home
- Source: src/screens/EnhancedPreferencesScreen.tsx

- Preference UI feedback:
- Selected genre/rating options show visual selected indicators
- Summary card appears when user has non-default selections
- Source: src/screens/EnhancedPreferencesScreen.tsx

- Slider clarification for Stitch:
- Live screens do not currently use a continuous slider control
- Slider-based mood intensity exists in architecture scaffold only (MoodSelector in ComponentStructure)
- Source: src/components/ComponentStructure.tsx
