/**
 * Hybrid Recommendation Service
 * 
 * Combines multiple recommendation strategies:
 * 1. Content-based filtering
 * 2. Collaborative filtering
 * 3. Machine learning models
 * 4. Mood-based recommendations
 * 5. Popularity-based fallbacks
 */

interface Movie {
  id: string;
  title: string;
  genres: string[];
  imdbRating: number;
  releaseYear: number;
  runtime: number;
  director: string;
  cast: string[];
  moodTags: string[];
  synopsis: string;
  popularity: number;
  features?: number[]; // ML feature vector
}

interface UserProfile {
  userId: string;
  preferences: {
    genres: string[];
    ratingRange: { min: number; max: number };
    preferredActors: string[];
    preferredDirectors: string[];
    excludedGenres: string[];
    excludedMovies: string[];
    streamingServices: string[];
  };
  watchHistory: WatchHistoryItem[];
  demographics?: {
    ageGroup: string;
    region: string;
  };
}

interface WatchHistoryItem {
  movieId: string;
  rating?: number;
  watchedAt: Date;
  moodAtTime?: string;
}

interface RecommendationContext {
  userId: string;
  currentMood?: {
    emoji: string;
    intensity: number;
    seriousnessLevel: number;
  };
  timeOfDay?: 'morning' | 'afternoon' | 'evening' | 'night';
  dayOfWeek?: string;
  seasonality?: 'spring' | 'summer' | 'fall' | 'winter';
}

interface RecommendationScore {
  movieId: string;
  score: number;
  confidence: number;
  explanation: string;
  algorithm: string;
  factors: {
    contentBased: number;
    collaborative: number;
    mlModel: number;
    moodBased: number;
    popularity: number;
    recency: number;
  };
}

interface RecommendationResult {
  movie: Movie;
  score: number;
  confidence: number;
  explanation: string;
  algorithm: string;
  isAlternative: boolean;
  alternativeReason?: string;
}

export class HybridRecommendationService {
  private contentBasedWeight = 0.25;
  private collaborativeWeight = 0.25;
  private mlModelWeight = 0.30;
  private moodBasedWeight = 0.15;
  private popularityWeight = 0.05;

  private movieDatabase: Map<string, Movie> = new Map();
  private userSimilarityMatrix: Map<string, Map<string, number>> = new Map();
  private itemSimilarityMatrix: Map<string, Map<string, number>> = new Map();

  constructor(
    private firebaseService: any,
    private mlService: any
  ) {
    this.initializeModels();
  }

  private async initializeModels(): Promise<void> {
    // Initialize recommendation models
    console.log('Initializing hybrid recommendation models...');
    
    // Load pre-computed similarity matrices
    await this.loadSimilarityMatrices();
    
    // Warm up ML models
    await this.mlService.warmUpModels();
  }

  /**
   * Generate hybrid recommendation for a user
   */
  async generateRecommendation(
    context: RecommendationContext
  ): Promise<RecommendationResult> {
    console.log(`Generating recommendation for user: ${context.userId}`);

    try {
      // Get user profile and preferences
      const userProfile = await this.firebaseService.getUserProfile(context.userId);
      if (!userProfile) {
        throw new Error('User profile not found');
      }

      // Get candidate movies
      const candidateMovies = await this.getCandidateMovies(userProfile);
      
      if (candidateMovies.length === 0) {
        return this.getFallbackRecommendation(userProfile, context);
      }

      // Score all candidate movies using hybrid approach
      const scoredMovies = await this.scoreMoviesHybrid(
        candidateMovies,
        userProfile,
        context
      );

      // Select best recommendation
      const bestRecommendation = this.selectBestRecommendation(scoredMovies);

      // Generate explanation
      const explanation = this.generateExplanation(bestRecommendation, userProfile, context);

      return {
        movie: await this.getMovieDetails(bestRecommendation.movieId),
        score: bestRecommendation.score,
        confidence: bestRecommendation.confidence,
        explanation,
        algorithm: 'hybrid',
        isAlternative: false
      };

    } catch (error) {
      console.error('Error generating recommendation:', error);
      return this.getEmergencyFallback(context);
    }
  }

  /**
   * Get candidate movies based on user preferences
   */
  private async getCandidateMovies(userProfile: UserProfile): Promise<Movie[]> {
    const candidates: Movie[] = [];
    
    // Get movies by preferred genres
    for (const genre of userProfile.preferences.genres) {
      const genreMovies = await this.firebaseService.searchMovies({
        genres: [genre],
        minRating: userProfile.preferences.ratingRange.min,
        maxRating: userProfile.preferences.ratingRange.max,
        limit: 100
      });
      candidates.push(...genreMovies);
    }

    // Remove duplicates and watched movies
    const watchedMovieIds = new Set(userProfile.watchHistory.map(item => item.movieId));
    const excludedMovieIds = new Set(userProfile.preferences.excludedMovies);
    
    const uniqueCandidates = candidates
      .filter(movie => !watchedMovieIds.has(movie.id))
      .filter(movie => !excludedMovieIds.has(movie.id))
      .filter(movie => !movie.genres.some(genre => 
        userProfile.preferences.excludedGenres.includes(genre)
      ));

    // Remove duplicates by ID
    const seen = new Set();
    return uniqueCandidates.filter(movie => {
      if (seen.has(movie.id)) {
        return false;
      }
      seen.add(movie.id);
      return true;
    });
  }

  /**
   * Score movies using hybrid approach
   */
  private async scoreMoviesHybrid(
    movies: Movie[],
    userProfile: UserProfile,
    context: RecommendationContext
  ): Promise<RecommendationScore[]> {
    const scores: RecommendationScore[] = [];

    for (const movie of movies) {
      const factors = {
        contentBased: await this.calculateContentBasedScore(movie, userProfile),
        collaborative: await this.calculateCollaborativeScore(movie, userProfile),
        mlModel: await this.calculateMLScore(movie, userProfile, context),
        moodBased: this.calculateMoodBasedScore(movie, context),
        popularity: this.calculatePopularityScore(movie),
        recency: this.calculateRecencyScore(movie)
      };

      // Calculate weighted hybrid score
      const hybridScore = 
        factors.contentBased * this.contentBasedWeight +
        factors.collaborative * this.collaborativeWeight +
        factors.mlModel * this.mlModelWeight +
        factors.moodBased * this.moodBasedWeight +
        factors.popularity * this.popularityWeight;

      // Calculate confidence based on factor agreement
      const confidence = this.calculateConfidence(factors);

      // Generate explanation
      const explanation = this.generateScoreExplanation(factors, movie);

      scores.push({
        movieId: movie.id,
        score: hybridScore,
        confidence,
        explanation,
        algorithm: 'hybrid',
        factors
      });
    }

    return scores.sort((a, b) => b.score - a.score);
  }

  /**
   * Content-based filtering score
   */
  private async calculateContentBasedScore(
    movie: Movie,
    userProfile: UserProfile
  ): Promise<number> {
    let score = 0;

    // Genre preference matching
    const genreMatchRatio = movie.genres.filter(genre => 
      userProfile.preferences.genres.includes(genre)
    ).length / userProfile.preferences.genres.length;
    score += genreMatchRatio * 40;

    // Rating preference
    const ratingRange = userProfile.preferences.ratingRange;
    if (movie.imdbRating >= ratingRange.min && movie.imdbRating <= ratingRange.max) {
      const ratingScore = ((movie.imdbRating - ratingRange.min) / 
        (ratingRange.max - ratingRange.min)) * 20;
      score += ratingScore;
    }

    // Actor preference
    const actorMatch = movie.cast.some(actor => 
      userProfile.preferences.preferredActors.includes(actor)
    );
    if (actorMatch) score += 15;

    // Director preference
    if (userProfile.preferences.preferredDirectors.includes(movie.director)) {
      score += 15;
    }

    // Historical genre preferences from watch history
    const watchedGenres = this.extractGenresFromWatchHistory(userProfile.watchHistory);
    const genreAffinityScore = this.calculateGenreAffinity(movie.genres, watchedGenres);
    score += genreAffinityScore * 10;

    return Math.min(100, Math.max(0, score));
  }

  /**
   * Collaborative filtering score
   */
  private async calculateCollaborativeScore(
    movie: Movie,
    userProfile: UserProfile
  ): Promise<number> {
    // Find similar users
    const similarUsers = await this.findSimilarUsers(userProfile.userId);
    
    if (similarUsers.length === 0) {
      return 50; // Neutral score if no similar users
    }

    let weightedRatingSum = 0;
    let totalWeight = 0;

    for (const [similarUserId, similarity] of similarUsers) {
      const similarUserProfile = await this.firebaseService.getUserProfile(similarUserId);
      if (!similarUserProfile) continue;

      // Check if similar user watched this movie
      const watchedItem = similarUserProfile.watchHistory.find(
        item => item.movieId === movie.id
      );

      if (watchedItem && watchedItem.rating) {
        weightedRatingSum += watchedItem.rating * similarity;
        totalWeight += similarity;
      }
    }

    if (totalWeight === 0) {
      return 50; // Neutral score if no ratings from similar users
    }

    const predictedRating = weightedRatingSum / totalWeight;
    return (predictedRating / 10) * 100; // Convert to 0-100 scale
  }

  /**
   * Machine learning model score
   */
  private async calculateMLScore(
    movie: Movie,
    userProfile: UserProfile,
    context: RecommendationContext
  ): Promise<number> {
    try {
      // Prepare feature vector
      const userFeatures = await this.extractUserFeatures(userProfile);
      const movieFeatures = await this.extractMovieFeatures(movie);
      const contextFeatures = this.extractContextFeatures(context);

      // Get ML prediction
      const prediction = await this.mlService.predict({
        userFeatures,
        movieFeatures,
        contextFeatures
      });

      return prediction * 100; // Convert to 0-100 scale
    } catch (error) {
      console.error('ML scoring failed:', error);
      return 50; // Neutral score on error
    }
  }

  /**
   * Mood-based score
   */
  private calculateMoodBasedScore(
    movie: Movie,
    context: RecommendationContext
  ): number {
    if (!context.currentMood) {
      return 50; // Neutral score if no mood provided
    }

    const moodTagMapping = {
      '😊': ['uplifting', 'funny', 'heartwarming'],
      '😨': ['intense', 'thrilling', 'suspenseful'],
      '😔': ['dramatic', 'thoughtful', 'melancholic'],
      '🤩': ['exciting', 'adventurous', 'epic'],
      '😍': ['romantic', 'passionate', 'intimate'],
      '🏃‍♂️': ['action-packed', 'energetic', 'dynamic'],
      '😌': ['peaceful', 'calming', 'relaxing'],
      '🤔': ['intellectual', 'complex', 'philosophical']
    };

    const requiredMoodTags = moodTagMapping[context.currentMood.emoji as keyof typeof moodTagMapping] || [];
    
    const moodMatchScore = movie.moodTags.filter(tag => 
      requiredMoodTags.includes(tag)
    ).length / requiredMoodTags.length;

    // Apply intensity weighting
    const intensityWeight = context.currentMood.intensity / 10;
    
    return moodMatchScore * intensityWeight * 100;
  }

  /**
   * Popularity score
   */
  private calculatePopularityScore(movie: Movie): number {
    // Simple popularity scoring based on IMDb rating and recency
    const ratingScore = (movie.imdbRating / 10) * 50;
    const popularityScore = (movie.popularity || 0) * 50;
    
    return Math.min(100, ratingScore + popularityScore);
  }

  /**
   * Recency score (boost newer movies slightly)
   */
  private calculateRecencyScore(movie: Movie): number {
    const currentYear = new Date().getFullYear();
    const movieAge = currentYear - movie.releaseYear;
    
    // Boost recent movies (within 5 years)
    if (movieAge <= 5) {
      return 100;
    } else if (movieAge <= 10) {
      return 75;
    } else if (movieAge <= 20) {
      return 50;
    } else {
      return 25;
    }
  }

  /**
   * Calculate confidence based on factor agreement
   */
  private calculateConfidence(factors: any): number {
    const scores = Object.values(factors) as number[];
    const mean = scores.reduce((sum, score) => sum + score, 0) / scores.length;
    
    // Calculate variance
    const variance = scores.reduce((sum, score) => sum + Math.pow(score - mean, 2), 0) / scores.length;
    const standardDeviation = Math.sqrt(variance);
    
    // Lower standard deviation = higher confidence
    const maxStdDev = 30; // Assuming scores range 0-100
    const confidence = Math.max(0, (maxStdDev - standardDeviation) / maxStdDev * 100);
    
    return confidence;
  }

  /**
   * Select best recommendation from scored movies
   */
  private selectBestRecommendation(scores: RecommendationScore[]): RecommendationScore {
    if (scores.length === 0) {
      throw new Error('No scored movies available');
    }

    // Consider both score and confidence
    const weightedScores = scores.map(score => ({
      ...score,
      weightedScore: score.score * 0.8 + score.confidence * 0.2
    }));

    return weightedScores.sort((a, b) => b.weightedScore - a.weightedScore)[0];
  }

  /**
   * Generate explanation for recommendation
   */
  private generateExplanation(
    recommendation: RecommendationScore,
    userProfile: UserProfile,
    context: RecommendationContext
  ): string {
    const explanationParts: string[] = [];

    // Add strongest factors
    const factors = recommendation.factors;
    const topFactors = Object.entries(factors)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 3);

    for (const [factor, score] of topFactors) {
      if (score > 60) {
        switch (factor) {
          case 'contentBased':
            explanationParts.push('matches your preferred genres and ratings');
            break;
          case 'collaborative':
            explanationParts.push('is loved by users with similar tastes');
            break;
          case 'mlModel':
            explanationParts.push('fits your viewing patterns perfectly');
            break;
          case 'moodBased':
            explanationParts.push('aligns with your current mood');
            break;
          case 'popularity':
            explanationParts.push('is highly rated and popular');
            break;
        }
      }
    }

    let explanation = `This recommendation ${explanationParts.join(', ')}.`;

    // Add confidence indicator
    if (recommendation.confidence > 80) {
      explanation = '🎯 Perfect match! ' + explanation;
    } else if (recommendation.confidence > 60) {
      explanation = '⭐ Great choice! ' + explanation;
    } else if (recommendation.confidence > 40) {
      explanation = '👍 Good pick! ' + explanation;
    }

    return explanation;
  }

  /**
   * Get fallback recommendation when main algorithm fails
   */
  private async getFallbackRecommendation(
    userProfile: UserProfile,
    context: RecommendationContext
  ): Promise<RecommendationResult> {
    // Get popular movies from user's preferred genres
    const popularMovies = await this.firebaseService.searchMovies({
      genres: userProfile.preferences.genres,
      minRating: Math.max(7.0, userProfile.preferences.ratingRange.min),
      limit: 10
    });

    if (popularMovies.length > 0) {
      const randomMovie = popularMovies[Math.floor(Math.random() * popularMovies.length)];
      
      return {
        movie: randomMovie,
        score: 75,
        confidence: 60,
        explanation: "We couldn't find a perfect match for your current preferences, so here's a highly-rated film from your favorite genres!",
        algorithm: 'fallback',
        isAlternative: true,
        alternativeReason: 'Limited matching movies for current criteria'
      };
    }

    return this.getEmergencyFallback(context);
  }

  /**
   * Emergency fallback when all else fails
   */
  private getEmergencyFallback(context: RecommendationContext): RecommendationResult {
    // Return a universally acclaimed movie
    const emergencyMovie: Movie = {
      id: 'emergency_1',
      title: 'The Shawshank Redemption',
      genres: ['drama'],
      imdbRating: 9.3,
      releaseYear: 1994,
      runtime: 142,
      director: 'Frank Darabont',
      cast: ['Tim Robbins', 'Morgan Freeman'],
      moodTags: ['inspiring', 'uplifting', 'dramatic'],
      synopsis: 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
      popularity: 100
    };

    return {
      movie: emergencyMovie,
      score: 85,
      confidence: 90,
      explanation: "Here's a universally beloved classic that appeals to almost everyone!",
      algorithm: 'emergency',
      isAlternative: true,
      alternativeReason: 'System fallback to ensure recommendation delivery'
    };
  }

  // Helper methods (simplified implementations)

  private async loadSimilarityMatrices(): Promise<void> {
    // Load pre-computed similarity matrices from storage
    console.log('Loading similarity matrices...');
  }

  private async findSimilarUsers(userId: string): Promise<[string, number][]> {
    // Return similar users with similarity scores
    const similarities = this.userSimilarityMatrix.get(userId);
    return similarities ? Array.from(similarities.entries()).slice(0, 50) : [];
  }

  private extractGenresFromWatchHistory(watchHistory: WatchHistoryItem[]): Map<string, number> {
    const genreCounts = new Map<string, number>();
    // Count genre preferences from watch history
    return genreCounts;
  }

  private calculateGenreAffinity(movieGenres: string[], userGenrePrefs: Map<string, number>): number {
    // Calculate how well movie genres match user's historical preferences
    return 50; // Placeholder
  }

  private async extractUserFeatures(userProfile: UserProfile): Promise<number[]> {
    // Extract numerical features for ML model
    return []; // Placeholder
  }

  private async extractMovieFeatures(movie: Movie): Promise<number[]> {
    // Extract numerical features for ML model
    return movie.features || [];
  }

  private extractContextFeatures(context: RecommendationContext): number[] {
    // Extract contextual features (time, mood, etc.)
    return []; // Placeholder
  }

  private generateScoreExplanation(factors: any, movie: Movie): string {
    return `Hybrid scoring: ${JSON.stringify(factors)}`;
  }

  private async getMovieDetails(movieId: string): Promise<Movie> {
    const movie = await this.firebaseService.getMovieData(movieId);
    return movie || this.getEmergencyFallback({} as RecommendationContext).movie;
  }
}
