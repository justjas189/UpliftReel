# Uplift Reel - Core Recommendation System Documentation

## Overview

Uplift Reel delivers personalized daily movie recommendations through an intelligent recommendation engine that considers user preferences, mood states, and viewing history. This document outlines the core recommendation logic, algorithms, and edge case handling strategies.

## System Architecture

### Core Components

1. **RecommendationEngine** - Main algorithmic logic for movie selection
2. **DailyRecommendationService** - Handles daily delivery and notifications
3. **MoodDetectionService** - Processes mood inputs and converts to filters
4. **UserPreferenceManager** - Manages user settings and constraints

## Recommendation Algorithm Flow

### 1. Input Processing
```
User Input → Preference Validation → Context Building → Algorithm Execution
```

**Input Components:**
- Selected genres (comedy, drama, thriller, horror, sci-fi, romance, action, documentary)
- IMDb rating range (1-10 scale)
- Mood input (emoji + intensity slider)
- Additional filters (actors, directors, release year, runtime)
- Exclusions (genres, specific movies)

### 2. Core Algorithm (Pseudocode)

```pseudo
FUNCTION findBestMatch(context, movieDatabase):
    // Step 1: Apply hard constraints
    filteredMovies = applyHardFilters(movieDatabase, context.userPreferences)
    
    // Step 2: Apply mood-based filtering
    IF context.currentMood EXISTS:
        moodTags = convertEmojiToMoodTags(context.currentMood.emoji)
        seriousnessLevel = context.currentMood.moodSlider
        filteredMovies = filterByMood(filteredMovies, moodTags, seriousnessLevel)
    
    // Step 3: Remove recently recommended movies
    filteredMovies = removeRecentMovies(filteredMovies, context.previousRecommendations)
    
    // Step 4: Calculate match scores and select best
    IF filteredMovies.length > 0:
        bestMatch = selectHighestScoringMovie(filteredMovies, context)
        RETURN createRecommendationResult(bestMatch, false)
    
    // Step 5: Handle edge cases
    edgeCaseResult = handleEdgeCases(context, movieDatabase)
    IF edgeCaseResult EXISTS:
        RETURN edgeCaseResult
    
    // Step 6: Fallback recommendation
    RETURN getFallbackRecommendation(context, movieDatabase)
```

### 3. Hard Filter Application

**Filter Hierarchy (All must pass):**
1. **Genre Match** - At least one genre must match user selection
2. **Rating Range** - IMDb rating within min/max bounds
3. **Exclusions** - Not in excluded genres or movies list
4. **Release Year** - Within specified year range (if set)
5. **Runtime** - Under maximum runtime limit (if set)

```pseudo
FUNCTION applyHardFilters(movies, preferences):
    RETURN movies.filter(movie =>
        hasMatchingGenre(movie.genres, preferences.selectedGenres) AND
        ratingInRange(movie.imdbRating, preferences.minRating, preferences.maxRating) AND
        notExcluded(movie, preferences.excludedGenres, preferences.excludedMovies) AND
        withinYearRange(movie.releaseYear, preferences.releaseYearRange) AND
        withinRuntimeLimit(movie.runtime, preferences.maxRuntime)
    )
```

### 4. Mood-Based Filtering

**Emoji to Mood Tag Mapping:**
- 😊 Happy → [Uplifting, Funny]
- 😨 Suspense → [Intense, Scary, Exciting]
- 😔 Introspective → [Thought-provoking, Nostalgic]
- 🤩 Excited → [Exciting, Uplifting]
- 😍 Romantic → [Romantic, Uplifting]
- 🏃‍♂️ Adventurous → [Exciting, Inspiring]
- 😌 Relaxed → [Relaxing, Uplifting]
- 🤔 Curious → [Thought-provoking, Inspiring]

**Seriousness Scale (1-10):**
- 1-3: Fun/Light (Comedy, Animation, Romance)
- 4-6: Balanced (Adventure, Action, Sci-fi)
- 7-10: Serious (Drama, Documentary, Thriller)

```pseudo
FUNCTION applyMoodFiltering(movies, moodInput):
    moodTags = convertEmojiToMoodTags(moodInput.emoji)
    targetSeriousness = moodInput.moodSlider
    tolerance = 2
    
    RETURN movies.filter(movie =>
        hasMatchingMoodTags(movie.moodTags, moodTags) AND
        abs(calculateMovieSeriousness(movie) - targetSeriousness) <= tolerance
    )
```

## Match Scoring System

### Scoring Components (Total: 100 points)

1. **Genre Match (40 points max)**
   - Perfect match: 40 points
   - Partial match: Proportional scoring
   - Formula: `(matchingGenres / selectedGenres) * 40`

2. **Rating Score (20 points max)**
   - Higher ratings within range get more points
   - Formula: `((rating - minRating) / (maxRating - minRating)) * 20`

3. **Preference Bonus (15 points max)**
   - Preferred actor match: +7.5 points
   - Preferred director match: +7.5 points

4. **Mood Match (15 points max)**
   - Formula: `(matchingMoodTags / requiredMoodTags) * 15`

5. **Runtime Preference (10 points max)**
   - Shorter movies get higher scores if maxRuntime is set
   - Formula: `max(0, (maxRuntime - movieRuntime) / maxRuntime * 10)`

```pseudo
FUNCTION calculateMatchScore(movie, context):
    score = 0
    
    // Genre matching (40 points)
    genreMatchRatio = countMatchingGenres(movie, context) / context.selectedGenres.length
    score += genreMatchRatio * 40
    
    // Rating score (20 points)
    ratingScore = (movie.rating - context.minRating) / (context.maxRating - context.minRating) * 20
    score += ratingScore
    
    // Preference bonuses (15 points)
    IF hasPreferredActor(movie, context.preferredActors):
        score += 7.5
    IF hasPreferredDirector(movie, context.preferredDirectors):
        score += 7.5
    
    // Mood matching (15 points)
    IF context.currentMood EXISTS:
        moodScore = calculateMoodScore(movie, context.currentMood)
        score += moodScore * 15
    
    // Runtime preference (10 points)
    IF context.maxRuntime EXISTS:
        runtimeScore = max(0, (context.maxRuntime - movie.runtime) / context.maxRuntime * 10)
        score += runtimeScore
    
    RETURN min(100, max(0, score))
```

## Edge Case Handling

### Strategy 1: Relaxed Rating Constraints
```pseudo
FUNCTION relaxRatingConstraints(context, movieDatabase):
    relaxedMin = max(1, context.minRating - 0.5)
    relaxedMax = min(10, context.maxRating + 0.5)
    
    movies = filterWithRelaxedRatings(movieDatabase, relaxedMin, relaxedMax)
    
    IF movies.length > 0:
        bestMatch = selectBestMatch(movies, context)
        explanation = generateAlternativeExplanation(bestMatch, "rating")
        RETURN createAlternativeRecommendation(bestMatch, explanation)
```

### Strategy 2: Genre Expansion
```pseudo
FUNCTION expandGenres(selectedGenres):
    relatedGenres = []
    FOR each genre IN selectedGenres:
        relatedGenres.addAll(GENRE_RELATIONS[genre])
    RETURN relatedGenres

GENRE_RELATIONS = {
    ACTION: [ADVENTURE, THRILLER],
    COMEDY: [ROMANCE, ANIMATION],
    DRAMA: [THRILLER, MYSTERY],
    HORROR: [THRILLER, MYSTERY],
    // ... more relations
}
```

### Strategy 3: Fallback Recommendation
```pseudo
FUNCTION getFallbackRecommendation(context, movieDatabase):
    // Find highest-rated movies from preferred genres
    fallbackMovies = movieDatabase
        .filter(hasAnyPreferredGenre)
        .sortBy(imdbRating, DESC)
        .excludeRecent(context.previousRecommendations)
    
    RETURN fallbackMovies[0] OR randomHighRatedMovie()
```

## Recommendation Explanation Generation

### Core Explanation Components
1. **Genre Match**: "This thriller matches your genre preferences"
2. **Rating Appeal**: "with its excellent 8.5/10 IMDb rating"
3. **Mood Alignment**: "and fits your current suspenseful mood"
4. **Personal Touch**: "featuring your favorite actor Tom Hanks"

### Confidence Indicators
- 90-100 points: "🎯 Perfect match!"
- 75-89 points: "⭐ Great choice!"
- 60-74 points: "👍 Good pick!"
- Below 60: Standard explanation

### Alternative Explanations
- **Rating variance**: "This is rated 6.8, just below your 7.0 minimum, but it's a cult classic in sci-fi!"
- **Genre expansion**: "While not exactly in your preferred genres, this action/adventure film shares similar themes and might surprise you!"

## Performance Considerations

### Optimization Strategies
1. **Pre-filtering**: Apply cheapest filters first
2. **Caching**: Cache mood tag conversions and genre relationships
3. **Batching**: Process multiple recommendations at once for efficiency
4. **Indexing**: Index movies by genre, rating, and year for faster filtering

### Scalability
- Algorithm complexity: O(n) where n = number of movies in database
- Memory usage: Linear with movie database size
- Recommendation generation: < 100ms for databases up to 100k movies

## Data Flow Diagram

```
User Input (Genres, Rating, Mood)
    ↓
Preference Validation & Context Building
    ↓
Hard Filter Application (Genre, Rating, Exclusions)
    ↓
Mood-Based Filtering (if mood provided)
    ↓
Recent Movie Removal
    ↓
Match Score Calculation
    ↓
Best Match Selection
    ↓
Edge Case Handling (if no matches)
    ↓
Recommendation Result Generation
    ↓
Explanation & Notification Creation
```

## Example Scenarios

### Scenario 1: Perfect Match
**Input**: Comedy + Drama, 7-9 rating, 😊 Happy mood, intensity 6
**Process**: 
1. Filter to Comedy/Drama movies rated 7-9
2. Apply happy mood filters (uplifting, funny tags)
3. Calculate scores, find 95-point match
**Output**: "🎯 Perfect match! This comedy/drama film matches your genre preferences with its excellent 8.2/10 IMDb rating and fits your current upbeat mood!"

### Scenario 2: Edge Case - Too Restrictive
**Input**: Documentary only, 9-10 rating, specific actor, last 5 years
**Process**:
1. Hard filters return 0 results
2. Relax rating to 8.5-10, find 3 matches
3. Select highest scoring alternative
**Output**: "This is rated 8.7, just below your 9.0 minimum, but it's highly regarded in documentary and features your preferred style!"

### Scenario 3: Mood Override
**Input**: All genres, 6-10 rating, 😨 Suspense mood, intensity 9
**Process**:
1. Filter all genres, ratings 6-10
2. Apply suspense mood (intense, scary, exciting tags)
3. Find thriller/horror matches despite user having comedy in preferences
**Output**: "⭐ Great choice! This thriller perfectly matches your suspenseful mood with intense scenes and a gripping 8.5/10 rated story!"

## Testing Strategy

### Unit Tests
- Filter logic validation
- Score calculation accuracy
- Edge case handling
- Mood conversion correctness

### Integration Tests
- End-to-end recommendation flow
- Preference persistence
- Notification delivery
- History tracking

### Performance Tests
- Large database handling
- Concurrent recommendation generation
- Memory usage optimization
- Response time benchmarks

This comprehensive recommendation system ensures that users receive highly personalized movie suggestions that align with their preferences, current mood, and cinematic desires while gracefully handling edge cases and maintaining excellent performance.
