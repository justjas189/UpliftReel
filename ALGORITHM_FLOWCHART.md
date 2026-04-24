# Uplift Reel - Recommendation Algorithm Flowchart

## High-Level Algorithm Flow

```
START: Daily Recommendation Request
    ↓
[1] Load User Context
    • User Preferences (genres, ratings, exclusions)
    • Current Mood Input (emoji, intensity, seriousness)
    • Recommendation History (last 30 recommendations)
    • Watched Movies List
    ↓
[2] Apply Hard Filters
    • Filter by Selected Genres (at least one match)
    • Filter by Rating Range (min ≤ rating ≤ max)
    • Remove Excluded Genres
    • Remove Excluded Movies
    • Apply Release Year Range (if set)
    • Apply Runtime Limit (if set)
    ↓
[3] Check Filter Results
    Movies Found? → YES: Continue to Step 4
                → NO: Jump to Step 7 (Edge Cases)
    ↓
[4] Apply Mood Filtering (if mood provided)
    • Convert Emoji to Mood Tags
    • Calculate Movie Seriousness Level
    • Filter by Mood Tag Matches
    • Apply Seriousness Tolerance (±2 points)
    ↓
[5] Remove Recent Movies
    • Remove Previous Recommendations (last 30)
    • Remove Watched Movies
    ↓
[6] Calculate Match Scores & Select Best
    For each remaining movie:
    • Genre Match Score (0-40 points)
    • Rating Score (0-20 points)
    • Preference Bonus (0-15 points)
    • Mood Match Score (0-15 points)
    • Runtime Score (0-10 points)
    ↓
    Select Highest Scoring Movie
    ↓
    Generate Perfect Match Result
    ↓
    END: Return Recommendation
    
[7] Edge Case Handling
    ↓
[7a] Strategy 1: Relax Rating Constraints
    • Expand rating range by ±0.5 points
    • Apply all other filters
    • Movies found? → YES: Select best match → Generate Alternative Result → END
                  → NO: Continue to 7b
    ↓
[7b] Strategy 2: Expand Genre Selection
    • Add related genres to user's selection
        - Action → Adventure, Thriller
        - Comedy → Romance, Animation
        - Drama → Thriller, Mystery
        - Horror → Thriller, Mystery
        - etc.
    • Apply expanded genre filter
    • Movies found? → YES: Select best match → Generate Alternative Result → END
                  → NO: Continue to 7c
    ↓
[7c] Strategy 3: Fallback Recommendation
    • Find highest-rated movies from ANY preferred genre
    • Exclude recently recommended/watched
    • Select top-rated option
    • Generate Fallback Result → END
```

## Detailed Component Flowcharts

### 1. Hard Filter Application
```
Input: Movie Database + User Preferences
    ↓
For each movie in database:
    ↓
    Check Genre Match:
    movie.genres ∩ user.selectedGenres ≠ ∅
    → NO: Remove movie
    → YES: Continue
    ↓
    Check Rating Range:
    user.minRating ≤ movie.imdbRating ≤ user.maxRating
    → NO: Remove movie
    → YES: Continue
    ↓
    Check Excluded Genres:
    movie.genres ∩ user.excludedGenres = ∅
    → NO: Remove movie
    → YES: Continue
    ↓
    Check Excluded Movies:
    movie.id ∉ user.excludedMovies
    → NO: Remove movie
    → YES: Continue
    ↓
    Check Release Year (if set):
    user.yearRange.min ≤ movie.year ≤ user.yearRange.max
    → NO: Remove movie
    → YES: Continue
    ↓
    Check Runtime (if set):
    movie.runtime ≤ user.maxRuntime
    → NO: Remove movie
    → YES: Keep movie
    ↓
Output: Filtered Movie List
```

### 2. Mood-Based Filtering
```
Input: Filtered Movies + Mood Input
    ↓
Convert Emoji to Mood Tags:
😊 → [uplifting, funny]
😨 → [intense, scary, exciting]
😔 → [thought-provoking, nostalgic]
🤩 → [exciting, uplifting]
😍 → [romantic, uplifting]
🏃‍♂️ → [exciting, inspiring]
😌 → [relaxing, uplifting]
🤔 → [thought-provoking, inspiring]
    ↓
Calculate Target Seriousness:
moodSlider value (1 = fun, 10 = serious)
    ↓
For each movie:
    ↓
    Check Mood Tag Match:
    movie.moodTags ∩ requiredMoodTags ≠ ∅
    → NO: Remove movie
    → YES: Continue
    ↓
    Calculate Movie Seriousness:
    Based on genre averages:
    • Comedy: 2, Romance: 4, Action: 6
    • Drama: 9, Documentary: 8, etc.
    ↓
    Check Seriousness Tolerance:
    |movieSeriousness - targetSeriousness| ≤ 2
    → NO: Remove movie
    → YES: Keep movie
    ↓
Output: Mood-Filtered Movie List
```

### 3. Match Score Calculation
```
Input: Movie + User Context
    ↓
Initialize score = 0
    ↓
[Genre Score - Max 40 points]
matchingGenres = movie.genres ∩ user.selectedGenres
ratio = matchingGenres.length / user.selectedGenres.length
score += ratio × 40
    ↓
[Rating Score - Max 20 points]
ratingNormalized = (movie.rating - user.minRating) / (user.maxRating - user.minRating)
score += ratingNormalized × 20
    ↓
[Preference Bonus - Max 15 points]
IF movie.actors ∩ user.preferredActors ≠ ∅:
    score += 7.5
IF movie.director ∈ user.preferredDirectors:
    score += 7.5
    ↓
[Mood Score - Max 15 points] (if mood provided)
moodMatchRatio = movie.moodTags ∩ requiredMoodTags.length / requiredMoodTags.length
score += moodMatchRatio × 15
    ↓
[Runtime Score - Max 10 points] (if maxRuntime set)
runtimeScore = max(0, (user.maxRuntime - movie.runtime) / user.maxRuntime × 10)
score += runtimeScore
    ↓
Final Score = min(100, max(0, score))
    ↓
Output: Movie Score (0-100)
```

### 4. Edge Case Strategy Decision Tree
```
No movies found after filtering
    ↓
Strategy 1: Relax Rating Constraints
    ↓
    newMinRating = max(1, user.minRating - 0.5)
    newMaxRating = min(10, user.maxRating + 0.5)
    ↓
    Apply relaxed rating filter
    ↓
    Movies found?
    → YES: Select best match
           Generate explanation:
           "Rated X.X, just below/above your Y.Y minimum/maximum, 
            but highly regarded in [genre]!"
           Return Alternative Recommendation
    → NO: Continue to Strategy 2
    ↓
Strategy 2: Genre Expansion
    ↓
    relatedGenres = getRelatedGenres(user.selectedGenres)
    expandedGenres = user.selectedGenres ∪ relatedGenres
    ↓
    Apply expanded genre filter (keep other constraints)
    ↓
    Movies found?
    → YES: Select best match
           Generate explanation:
           "While not exactly in your preferred genres, 
            this [movie.genres] film shares similar themes!"
           Return Alternative Recommendation
    → NO: Continue to Strategy 3
    ↓
Strategy 3: Fallback System
    ↓
    Find movies with ANY preferred genre
    Sort by IMDb rating (descending)
    Remove recently recommended/watched
    ↓
    Select top-rated movie OR random high-rated movie
    ↓
    Generate explanation:
    "Couldn't find perfect match, here's a highly-rated 
     [genre] film that many users love!"
    ↓
    Return Fallback Recommendation
```

### 5. Explanation Generation Logic
```
Input: Recommended Movie + Context + Match Score
    ↓
Initialize explanation parts = []
    ↓
Add Genre Match:
IF matchingGenres.length > 0:
    parts.add("This [genres] film matches your genre preferences")
    ↓
Add Rating Appeal:
IF movie.rating ≥ user.minRating:
    parts.add("with its excellent [rating]/10 IMDb rating")
    ↓
Add Mood Context (if mood provided):
moodDescription = getMoodDescription(user.mood.emoji)
parts.add("and fits your current [moodDescription] mood")
    ↓
Add Personal Touch:
IF hasPreferredActor(movie, user.preferredActors):
    actor = getMatchingActor(movie, user.preferredActors)
    parts.add("featuring your favorite actor [actor]")
IF hasPreferredDirector(movie, user.preferredDirectors):
    parts.add("directed by [director], whom you love")
    ↓
Combine Parts:
explanation = parts.join(", ") + "!"
    ↓
Add Confidence Indicator:
IF score ≥ 90: prefix = "🎯 Perfect match! "
ELSE IF score ≥ 75: prefix = "⭐ Great choice! "
ELSE IF score ≥ 60: prefix = "👍 Good pick! "
ELSE: prefix = ""
    ↓
Final Explanation = prefix + explanation
    ↓
Output: Generated Explanation String
```

## Data Structures

### User Context Structure
```
RecommendationContext {
    userPreferences: {
        selectedGenres: Genre[],
        minRating: number (1-10),
        maxRating: number (1-10),
        preferredActors: string[],
        preferredDirectors: string[],
        releaseYearRange: {min: number, max: number},
        maxRuntime: number,
        excludedGenres: Genre[],
        excludedMovies: string[],
        notificationTime: string
    },
    currentMood: {
        emoji: MoodEmoji,
        intensity: number (1-10),
        moodSlider: number (1-10)
    },
    previousRecommendations: string[],
    watchedMovies: string[]
}
```

### Movie Data Structure
```
Movie {
    id: string,
    title: string,
    genre: Genre[],
    imdbRating: number (1-10),
    releaseYear: number,
    runtime: number (minutes),
    synopsis: string,
    trailerUrl: string,
    director: string,
    actors: string[],
    moodTags: MoodTag[],
    posterUrl: string
}
```

### Recommendation Result
```
RecommendationResult {
    movie: Movie,
    matchScore: number (0-100),
    explanation: string,
    isAlternative: boolean,
    alternativeReason?: string
}
```

## Performance Considerations

### Algorithm Complexity
- **Time Complexity**: O(n) where n = number of movies in database
- **Space Complexity**: O(n) for storing filtered results
- **Optimization**: Early filtering reduces dataset size quickly

### Filtering Order (Most to Least Restrictive)
1. Excluded movies (exact match)
2. Genre matching (intersection operation)
3. Rating range (numerical comparison)
4. Release year range (numerical comparison)
5. Runtime limit (numerical comparison)
6. Mood filtering (array intersection)
7. Recent movie removal (array lookup)

This flowchart represents the complete recommendation algorithm logic, ensuring users receive personalized movie suggestions that align with their preferences and current mood while gracefully handling edge cases.
