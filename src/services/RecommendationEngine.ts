/**
 * Core Recommendation Engine for Uplift Reel
 * 
 * This engine implements the daily movie recommendation logic based on:
 * - User genre preferences
 * - IMDb rating range
 * - Mood-based filtering
 * - Additional preference filters
 * - Edge case handling for strict criteria
 */

import {
  Movie,
  Genre,
  MoodTag,
  MoodEmoji,
  UserPreferences,
  MoodInput,
  RecommendationContext,
  RecommendationResult,
  RecommendationEngine
} from '../types';

export class UpliftReelRecommendationEngine implements RecommendationEngine {
  
  /**
   * Main recommendation method that finds the best movie match
   * 
   * ALGORITHM FLOW:
   * 1. Filter movies by hard constraints (genre, rating, exclusions)
   * 2. Apply mood-based filtering if mood is provided
   * 3. Calculate match scores for remaining movies
   * 4. Select highest scoring movie not recently recommended
   * 5. Handle edge cases if no perfect matches found
   */
  findBestMatch(context: RecommendationContext, movieDatabase: Movie[]): RecommendationResult {
    console.log('🎬 Starting recommendation process...');
    
    // Step 1: Apply hard filters
    let filteredMovies = this.applyHardFilters(movieDatabase, context);
    console.log(`📊 After hard filters: ${filteredMovies.length} movies remaining`);
    
    // Step 2: Apply mood filtering if mood is provided
    if (context.currentMood) {
      filteredMovies = this.applyMoodFiltering(filteredMovies, context.currentMood);
      console.log(`🎭 After mood filtering: ${filteredMovies.length} movies remaining`);
    }
    
    // Step 3: Remove recently recommended and watched movies
    filteredMovies = this.removeRecentMovies(filteredMovies, context);
    console.log(`🔄 After removing recent movies: ${filteredMovies.length} movies remaining`);
    
    // Step 4: If we have matches, find the best one
    if (filteredMovies.length > 0) {
      const bestMatch = this.selectBestMatch(filteredMovies, context);
      return {
        movie: bestMatch.movie,
        matchScore: bestMatch.score,
        explanation: this.generateExplanation(bestMatch.movie, context, bestMatch.score),
        isAlternative: false
      };
    }
    
    // Step 5: Handle edge cases - no perfect matches found
    console.log('⚠️ No perfect matches found, handling edge cases...');
    const edgeCaseResult = this.handleEdgeCases(context, movieDatabase);
    
    if (edgeCaseResult) {
      return edgeCaseResult;
    }
    
    // Fallback: return a random highly-rated movie from preferred genres
    return this.getFallbackRecommendation(context, movieDatabase);
  }
  
  /**
   * Apply hard constraints that cannot be compromised
   */
  private applyHardFilters(movies: Movie[], context: RecommendationContext): Movie[] {
    const { userPreferences } = context;
    
    return movies.filter(movie => {
      // Genre filter - at least one genre must match
      const hasMatchingGenre = movie.genre.some(genre => 
        userPreferences.selectedGenres.includes(genre)
      );
      if (!hasMatchingGenre) return false;
      
      // Rating filter
      if (movie.imdbRating < userPreferences.minRating || 
          movie.imdbRating > userPreferences.maxRating) {
        return false;
      }
      
      // Excluded genres
      if (userPreferences.excludedGenres?.some(excludedGenre => 
          movie.genre.includes(excludedGenre))) {
        return false;
      }
      
      // Excluded movies
      if (userPreferences.excludedMovies?.includes(movie.id)) {
        return false;
      }
      
      // Release year range
      if (userPreferences.releaseYearRange) {
        const { min, max } = userPreferences.releaseYearRange;
        if (movie.releaseYear < min || movie.releaseYear > max) {
          return false;
        }
      }
      
      // Max runtime
      if (userPreferences.maxRuntime && movie.runtime > userPreferences.maxRuntime) {
        return false;
      }
      
      return true;
    });
  }
  
  /**
   * Apply mood-based filtering using emoji and slider inputs
   */
  private applyMoodFiltering(movies: Movie[], moodInput: MoodInput): Movie[] {
    const moodTags = this.convertEmojiToMoodTags(moodInput.emoji);
    const seriousnessLevel = moodInput.moodSlider; // 1 = fun, 10 = serious
    
    return movies.filter(movie => {
      // Check if movie has matching mood tags
      const hasMoodMatch = movie.moodTags.some(tag => moodTags.includes(tag));
      
      // Apply seriousness filter based on genre
      const movieSeriousness = this.calculateMovieSeriousness(movie);
      const seriousnessTolerance = 2; // Allow some variance
      
      const seriousnessMatch = Math.abs(movieSeriousness - seriousnessLevel) <= seriousnessTolerance;
      
      return hasMoodMatch && seriousnessMatch;
    });
  }
  
  /**
   * Convert mood emoji to corresponding mood tags
   */
  private convertEmojiToMoodTags(emoji: MoodEmoji): MoodTag[] {
    const emojiToMoodMap: Record<MoodEmoji, MoodTag[]> = {
      [MoodEmoji.HAPPY]: [MoodTag.UPLIFTING, MoodTag.FUNNY],
      [MoodEmoji.SUSPENSE]: [MoodTag.INTENSE, MoodTag.SCARY, MoodTag.EXCITING],
      [MoodEmoji.INTROSPECTIVE]: [MoodTag.THOUGHT_PROVOKING, MoodTag.NOSTALGIC],
      [MoodEmoji.EXCITED]: [MoodTag.EXCITING, MoodTag.UPLIFTING],
      [MoodEmoji.ROMANTIC]: [MoodTag.ROMANTIC, MoodTag.UPLIFTING],
      [MoodEmoji.ADVENTUROUS]: [MoodTag.EXCITING, MoodTag.INSPIRING],
      [MoodEmoji.RELAXED]: [MoodTag.RELAXING, MoodTag.UPLIFTING],
      [MoodEmoji.CURIOUS]: [MoodTag.THOUGHT_PROVOKING, MoodTag.INSPIRING]
    };
    
    return emojiToMoodMap[emoji] || [];
  }
  
  /**
   * Calculate how serious a movie is (1-10 scale)
   */
  private calculateMovieSeriousness(movie: Movie): number {
    const genreSeriousness: Record<Genre, number> = {
      [Genre.COMEDY]: 2,
      [Genre.ROMANCE]: 4,
      [Genre.ADVENTURE]: 5,
      [Genre.ACTION]: 6,
      [Genre.SCIFI]: 6,
      [Genre.FANTASY]: 5,
      [Genre.ANIMATION]: 3,
      [Genre.MYSTERY]: 7,
      [Genre.THRILLER]: 8,
      [Genre.DRAMA]: 9,
      [Genre.HORROR]: 7,
      [Genre.DOCUMENTARY]: 8
    };
    
    const avgSeriousness = movie.genre.reduce((sum, genre) => 
      sum + genreSeriousness[genre], 0) / movie.genre.length;
    
    return Math.round(avgSeriousness);
  }
  
  /**
   * Remove recently recommended and watched movies
   */
  private removeRecentMovies(movies: Movie[], context: RecommendationContext): Movie[] {
    const { previousRecommendations, watchedMovies } = context;
    
    return movies.filter(movie => 
      !previousRecommendations.includes(movie.id) && 
      !watchedMovies.includes(movie.id)
    );
  }
  
  /**
   * Calculate match score for a movie (0-100)
   */
  calculateMatchScore(movie: Movie, context: RecommendationContext): number {
    const { userPreferences, currentMood } = context;
    let score = 0;
    
    // Genre match score (40 points max)
    const genreMatchRatio = movie.genre.filter(genre => 
      userPreferences.selectedGenres.includes(genre)
    ).length / userPreferences.selectedGenres.length;
    score += genreMatchRatio * 40;
    
    // Rating score (20 points max) - closer to max preferred rating gets higher score
    const ratingScore = ((movie.imdbRating - userPreferences.minRating) / 
      (userPreferences.maxRating - userPreferences.minRating)) * 20;
    score += ratingScore;
    
    // Preferred actors/directors bonus (15 points max)
    let preferenceBonus = 0;
    if (userPreferences.preferredActors?.some(actor => 
        movie.actors.includes(actor))) {
      preferenceBonus += 7.5;
    }
    if (userPreferences.preferredDirectors?.includes(movie.director)) {
      preferenceBonus += 7.5;
    }
    score += preferenceBonus;
    
    // Mood match score (15 points max)
    if (currentMood) {
      const moodTags = this.convertEmojiToMoodTags(currentMood.emoji);
      const moodMatchRatio = movie.moodTags.filter(tag => 
        moodTags.includes(tag)
      ).length / moodTags.length;
      score += moodMatchRatio * 15;
    }
    
    // Runtime preference score (10 points max)
    if (userPreferences.maxRuntime) {
      const runtimeScore = Math.max(0, 
        (userPreferences.maxRuntime - movie.runtime) / userPreferences.maxRuntime * 10
      );
      score += runtimeScore;
    }
    
    return Math.min(100, Math.max(0, score));
  }
  
  /**
   * Select the best match from filtered movies
   */
  private selectBestMatch(movies: Movie[], context: RecommendationContext): { movie: Movie; score: number } {
    let bestMovie = movies[0];
    let bestScore = this.calculateMatchScore(bestMovie, context);
    
    for (const movie of movies.slice(1)) {
      const score = this.calculateMatchScore(movie, context);
      if (score > bestScore) {
        bestMovie = movie;
        bestScore = score;
      }
    }
    
    return { movie: bestMovie, score: bestScore };
  }
  
  /**
   * Handle edge cases when no movies match strict criteria
   */
  handleEdgeCases(context: RecommendationContext, movieDatabase: Movie[]): RecommendationResult | null {
    const { userPreferences } = context;
    
    // Strategy 1: Relax rating constraints slightly
    const relaxedRatingMovies = movieDatabase.filter(movie => {
      const hasMatchingGenre = movie.genre.some(genre => 
        userPreferences.selectedGenres.includes(genre)
      );
      
      const relaxedMinRating = Math.max(1, userPreferences.minRating - 0.5);
      const relaxedMaxRating = Math.min(10, userPreferences.maxRating + 0.5);
      
      return hasMatchingGenre && 
             movie.imdbRating >= relaxedMinRating && 
             movie.imdbRating <= relaxedMaxRating &&
             !userPreferences.excludedMovies?.includes(movie.id) &&
             !context.previousRecommendations.includes(movie.id) &&
             !context.watchedMovies.includes(movie.id);
    });
    
    if (relaxedRatingMovies.length > 0) {
      const bestMatch = this.selectBestMatch(relaxedRatingMovies, context);
      const ratingDiff = Math.abs(bestMatch.movie.imdbRating - userPreferences.minRating);
      
      return {
        movie: bestMatch.movie,
        matchScore: bestMatch.score,
        explanation: this.generateAlternativeExplanation(bestMatch.movie, context, 'rating'),
        isAlternative: true,
        alternativeReason: `This is rated ${bestMatch.movie.imdbRating}, ${ratingDiff < 1 ? 'just' : ''} ${
          bestMatch.movie.imdbRating < userPreferences.minRating ? 'below' : 'above'
        } your ${bestMatch.movie.imdbRating < userPreferences.minRating ? 'minimum' : 'maximum'} of ${
          bestMatch.movie.imdbRating < userPreferences.minRating ? userPreferences.minRating : userPreferences.maxRating
        }, but it's highly regarded in ${(bestMatch.movie.genre || []).join(', ')}!`
      };
    }
    
    // Strategy 2: Expand to related genres
    const relatedGenres = this.getRelatedGenres(userPreferences.selectedGenres);
    const expandedGenreMovies = movieDatabase.filter(movie => {
      const hasRelatedGenre = movie.genre.some(genre => relatedGenres.includes(genre));
      return hasRelatedGenre &&
             movie.imdbRating >= userPreferences.minRating &&
             movie.imdbRating <= userPreferences.maxRating &&
             !userPreferences.excludedMovies?.includes(movie.id) &&
             !context.previousRecommendations.includes(movie.id) &&
             !context.watchedMovies.includes(movie.id);
    });
    
    if (expandedGenreMovies.length > 0) {
      const bestMatch = this.selectBestMatch(expandedGenreMovies, context);
      return {
        movie: bestMatch.movie,
        matchScore: bestMatch.score,
        explanation: this.generateAlternativeExplanation(bestMatch.movie, context, 'genre'),
        isAlternative: true,
        alternativeReason: `While not exactly in your preferred genres, this ${(bestMatch.movie.genre || []).join('/')} film shares similar themes and might surprise you!`
      };
    }
    
    return null;
  }
  
  /**
   * Get related genres for genre expansion
   */
  private getRelatedGenres(selectedGenres: Genre[]): Genre[] {
    const genreRelations: Record<Genre, Genre[]> = {
      [Genre.ACTION]: [Genre.ADVENTURE, Genre.THRILLER],
      [Genre.ADVENTURE]: [Genre.ACTION, Genre.FANTASY],
      [Genre.COMEDY]: [Genre.ROMANCE, Genre.ANIMATION],
      [Genre.DRAMA]: [Genre.THRILLER, Genre.MYSTERY],
      [Genre.HORROR]: [Genre.THRILLER, Genre.MYSTERY],
      [Genre.ROMANCE]: [Genre.COMEDY, Genre.DRAMA],
      [Genre.SCIFI]: [Genre.FANTASY, Genre.ADVENTURE],
      [Genre.THRILLER]: [Genre.MYSTERY, Genre.HORROR, Genre.ACTION],
      [Genre.DOCUMENTARY]: [Genre.DRAMA],
      [Genre.FANTASY]: [Genre.ADVENTURE, Genre.SCIFI],
      [Genre.MYSTERY]: [Genre.THRILLER, Genre.DRAMA],
      [Genre.ANIMATION]: [Genre.COMEDY, Genre.ADVENTURE]
    };
    
    const related = new Set<Genre>();
    selectedGenres.forEach(genre => {
      genreRelations[genre]?.forEach(relatedGenre => related.add(relatedGenre));
    });
    
    return Array.from(related);
  }
  
  /**
   * Fallback recommendation when all else fails
   */
  private getFallbackRecommendation(context: RecommendationContext, movieDatabase: Movie[]): RecommendationResult {
    // Find highest-rated movies from any of the user's preferred genres
    const fallbackMovies = movieDatabase
      .filter(movie => {
        const hasPreferredGenre = movie.genre.some(genre => 
          context.userPreferences.selectedGenres.includes(genre)
        );
        return hasPreferredGenre && 
               !context.previousRecommendations.includes(movie.id) &&
               !context.watchedMovies.includes(movie.id);
      })
      .sort((a, b) => b.imdbRating - a.imdbRating);
    
    const fallbackMovie = fallbackMovies[0] || movieDatabase[Math.floor(Math.random() * movieDatabase.length)];
    
    return {
      movie: fallbackMovie,
      matchScore: 50,
      explanation: `We couldn't find a perfect match for your current preferences, so here's a highly-rated ${(fallbackMovie.genre || []).join('/')} film that many users love!`,
      isAlternative: true,
      alternativeReason: 'Your preferences are quite specific, so we picked a crowd favorite instead!'
    };
  }
  
  /**
   * Generate explanation for why this movie was recommended
   */
  private generateExplanation(movie: Movie, context: RecommendationContext, score: number): string {
    const { userPreferences, currentMood } = context;
    const explanationParts: string[] = [];
    
    // Genre match
    const matchingGenres = movie.genre.filter(genre => 
      userPreferences.selectedGenres.includes(genre)
    );
    if (matchingGenres.length > 0) {
      explanationParts.push(`This ${matchingGenres.join('/')} film matches your genre preferences`);
    }
    
    // Rating
    if (movie.imdbRating >= userPreferences.minRating) {
      explanationParts.push(`with its excellent ${movie.imdbRating}/10 IMDb rating`);
    }
    
    // Mood match
    if (currentMood) {
      const moodDescription = this.getMoodDescription(currentMood.emoji);
      explanationParts.push(`and fits your current ${moodDescription} mood`);
    }
    
    // Special mentions
    if (userPreferences.preferredActors?.some(actor => movie.actors.includes(actor))) {
      const matchingActor = movie.actors.find(actor => userPreferences.preferredActors!.includes(actor));
      explanationParts.push(`featuring your favorite actor ${matchingActor}`);
    }
    
    if (userPreferences.preferredDirectors?.includes(movie.director)) {
      explanationParts.push(`directed by ${movie.director}, whom you love`);
    }
    
    let explanation = explanationParts.join(', ') + '!';
    
    // Add confidence indicator
    if (score >= 90) {
      explanation = '🎯 Perfect match! ' + explanation;
    } else if (score >= 75) {
      explanation = '⭐ Great choice! ' + explanation;
    } else if (score >= 60) {
      explanation = '👍 Good pick! ' + explanation;
    }
    
    return explanation;
  }
  
  /**
   * Generate explanation for alternative recommendations
   */
  private generateAlternativeExplanation(movie: Movie, context: RecommendationContext, reason: string): string {
    const baseExplanation = this.generateExplanation(movie, context, 70);
    
    if (reason === 'rating') {
      return `While the rating doesn't perfectly match your range, ${baseExplanation.toLowerCase()}`;
    } else if (reason === 'genre') {
      return `Though it's outside your usual genres, ${baseExplanation.toLowerCase()}`;
    }
    
    return baseExplanation;
  }
  
  /**
   * Get mood description from emoji
   */
  private getMoodDescription(emoji: MoodEmoji): string {
    const moodDescriptions: Record<MoodEmoji, string> = {
      [MoodEmoji.HAPPY]: 'upbeat',
      [MoodEmoji.SUSPENSE]: 'thrilling',
      [MoodEmoji.INTROSPECTIVE]: 'contemplative',
      [MoodEmoji.EXCITED]: 'energetic',
      [MoodEmoji.ROMANTIC]: 'romantic',
      [MoodEmoji.ADVENTUROUS]: 'adventurous',
      [MoodEmoji.RELAXED]: 'chill',
      [MoodEmoji.CURIOUS]: 'thought-provoking'
    };
    
    return moodDescriptions[emoji] || 'current';
  }
}
