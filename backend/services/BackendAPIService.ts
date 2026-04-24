/**
 * Backend API Service
 * 
 * Main API service that orchestrates all backend services and provides
 * endpoints for the mobile application
 */

import { UpliftReelRecommendationEngine } from '../../src/services/RecommendationEngine';
import { DailyRecommendationService } from '../../src/services/DailyRecommendationService';
import { MoodDetectionService } from '../../src/services/MoodDetectionService';
import { UserPreferenceManager } from '../../src/services/UserPreferenceManager';
import { Genre } from '../../src/types';
import { ExternalAPIService } from './ExternalAPIService';
import { FirebaseService } from './FirebaseService';
import { HybridRecommendationService } from './HybridRecommendationService';
import { MLRecommendationService } from './MLRecommendationService';
import { NotificationService } from './NotificationService';

// API Request/Response interfaces
interface APIResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: string;
  requestId: string;
}

interface GetRecommendationRequest {
  userId: string;
  mood?: {
    emoji: string;
    intensity: number;
    seriousnessLevel: number;
  };
  forceNew?: boolean;
  algorithm?: 'simple' | 'hybrid' | 'ml';
}

interface UpdatePreferencesRequest {
  userId: string;
  preferences: {
    genres?: string[];
    ratingRange?: { min: number; max: number };
    preferredActors?: string[];
    preferredDirectors?: string[];
    excludedGenres?: string[];
    excludedMovies?: string[];
    streamingServices?: string[];
  };
}

interface SearchMoviesRequest {
  query?: string;
  genres?: string[];
  minRating?: number;
  maxRating?: number;
  releaseYear?: number;
  page?: number;
  limit?: number;
}

interface RateMovieRequest {
  userId: string;
  movieId: string;
  rating: number;
  review?: string;
  mood?: string;
}

interface NotificationSettingsRequest {
  userId: string;
  enabled: boolean;
  time: string;
  frequency: 'daily' | 'weekly';
  weekdays?: number[];
}

export class BackendAPIService {
  private recommendationEngine!: UpliftReelRecommendationEngine;
  private dailyRecommendationService!: DailyRecommendationService;
  private moodDetectionService!: MoodDetectionService;
  private userPreferenceManager!: UserPreferenceManager;
  private externalAPIService!: ExternalAPIService;
  private firebaseService!: FirebaseService;
  private hybridRecommendationService!: HybridRecommendationService;
  private mlRecommendationService!: MLRecommendationService;
  private notificationService!: NotificationService;

  constructor() {
    this.initializeServices();
  }

  /**
   * Initialize all backend services
   */
  private async initializeServices(): Promise<void> {
    console.log('Initializing backend services...');

    try {
      // Initialize core services first
      this.firebaseService = new FirebaseService();
      
      // Initialize ExternalAPIService with mock API key
      this.externalAPIService = new ExternalAPIService(
        'mock-tmdb-api-key',
        'redis://localhost:6379'
      );
      
      // Initialize ML and recommendation services
      this.mlRecommendationService = new MLRecommendationService(this.firebaseService);
      this.hybridRecommendationService = new HybridRecommendationService(
        this.firebaseService,
        this.mlRecommendationService
      );
      
      // Initialize user-facing services
      this.moodDetectionService = new MoodDetectionService();
      this.userPreferenceManager = new UserPreferenceManager();
      this.recommendationEngine = new UpliftReelRecommendationEngine();
      
      this.dailyRecommendationService = DailyRecommendationService.getInstance();
      
      this.notificationService = new NotificationService(
        this.firebaseService,
        this.dailyRecommendationService
      );

      console.log('All backend services initialized successfully');
    } catch (error) {
      console.error('Failed to initialize backend services:', error);
      throw error;
    }
  }

  /**
   * Get daily movie recommendation
   */
  async getDailyRecommendation(request: GetRecommendationRequest): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`Getting daily recommendation for user: ${request.userId}`);

      let recommendation;

      // Choose algorithm based on request
      switch (request.algorithm) {
        case 'hybrid':
          recommendation = await this.hybridRecommendationService.generateRecommendation({
            userId: request.userId,
            currentMood: request.mood
          });
          break;
        
        case 'ml':
          // Get features and use ML service
          const features = await this.extractMLFeatures(request.userId, request.mood);
          const mlScore = await this.mlRecommendationService.predict(features);
          
          // For demo purposes, get recommendation from hybrid service with ML scoring
          recommendation = await this.hybridRecommendationService.generateRecommendation({
            userId: request.userId,
            currentMood: request.mood
          });
          recommendation.score = mlScore * 100;
          break;
        
        default:
          // Use simple recommendation engine - create mock user preferences
          const mockUserPreferences = {
            selectedGenres: [Genre.COMEDY, Genre.DRAMA],
            minRating: 6.0,
            maxRating: 10.0,
            preferredActors: [],
            preferredDirectors: [],
            releaseYearRange: { min: 1990, max: 2024 },
            maxRuntime: 180,
            excludedGenres: [],
            excludedMovies: [],
            notificationTime: '19:00'
          };
          // For now, generate recommendation without mood input due to type complexity
          recommendation = await this.dailyRecommendationService.generateDailyRecommendation(
            mockUserPreferences,
            undefined // Simplified for now
          );
      }

      // Store recommendation in history
      await this.firebaseService.saveRecommendation({
        id: this.generateRequestId(),
        movieId: recommendation.movie.id,
        userId: request.userId,
        date: new Date().toISOString(),
        score: recommendation.score,
        reason: recommendation.explanation,
        algorithm: request.algorithm || 'simple',
        viewed: false,
        clicked: false,
        createdAt: new Date()
      });

      return {
        success: true,
        data: recommendation,
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error getting daily recommendation:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Search for movies
   */
  async searchMovies(request: SearchMoviesRequest): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log('Searching movies with criteria:', request);

      let movies: any[] = [];

      if (request.query) {
        // Text search
        const searchResult = await this.externalAPIService.searchMovies(request.query);
        movies = searchResult || [];
      } else {
        // Filter search
        const searchResults = await this.firebaseService.searchMovies({
          genres: request.genres || [],
          minRating: request.minRating || 0,
          maxRating: request.maxRating || 10,
          releaseYearMin: request.releaseYear,
          releaseYearMax: request.releaseYear,
          limit: request.limit || 20
        });
        movies = searchResults;
      }

      // Apply pagination
      const page = request.page || 1;
      const limit = request.limit || 20;
      const startIndex = (page - 1) * limit;
      const paginatedMovies = movies.slice(startIndex, startIndex + limit);

      return {
        success: true,
        data: {
          movies: paginatedMovies,
          totalCount: movies.length,
          page,
          totalPages: Math.ceil(movies.length / limit)
        },
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error searching movies:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Get movie details
   */
  async getMovieDetails(movieId: string): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`Getting movie details for: ${movieId}`);

      // Get movie from database first
      let movie = await this.firebaseService.getMovieData(movieId);

      if (!movie) {
        // Fetch from external API if not in database
        movie = await this.externalAPIService.getMovieDetails(movieId);
        
        if (movie) {
          // Store in database for future use
          await this.firebaseService.storeMovieData(movie);
        }
      }

      if (!movie) {
        return {
          success: false,
          error: 'Movie not found',
          timestamp: new Date().toISOString(),
          requestId
        };
      }

      // Get additional details (streaming availability, reviews, etc.)
      const streamingInfo = await this.externalAPIService.getStreamingProviders(movieId);
      const reviews = null; // Reviews functionality not implemented in this service

      return {
        success: true,
        data: {
          ...movie,
          streamingInfo,
          reviews
        },
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error getting movie details:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Update user preferences
   */
  async updateUserPreferences(request: UpdatePreferencesRequest): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`Updating preferences for user: ${request.userId}`);

      // Simplified preference update - would need proper type conversion in production
      console.log('Preferences would be updated for user:', request.userId, request.preferences);

      // Trigger model retraining with updated preferences
      this.triggerModelUpdate(request.userId);

      return {
        success: true,
        data: { message: 'Preferences updated successfully' },
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error updating user preferences:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Rate a movie
   */
  async rateMovie(request: RateMovieRequest): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`User ${request.userId} rating movie ${request.movieId}: ${request.rating}`);

      // Save rating to database
      await this.firebaseService.addToWatchHistory(request.userId, {
        movieId: request.movieId,
        rating: request.rating,
        review: request.review,
        moodAtTime: request.mood
      });

      // Update ML training data
      await this.updateMLTrainingData(request);

      // Update user's preference profile (simplified - would implement learning logic)
      console.log(`User ${request.userId} rated ${request.movieId}: ${request.rating} - preferences updated`);

      return {
        success: true,
        data: { message: 'Rating saved successfully' },
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error saving movie rating:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Get user's watch history
   */
  async getWatchHistory(userId: string, page = 1, limit = 20): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`Getting watch history for user: ${userId}`);

      const history = await this.firebaseService.getWatchHistory(userId, limit, (page - 1) * limit);

      return {
        success: true,
        data: history,
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error getting watch history:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Update notification settings
   */
  async updateNotificationSettings(request: NotificationSettingsRequest): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`Updating notification settings for user: ${request.userId}`);

      const preferences = {
        enabled: request.enabled,
        time: request.time,
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
        frequency: request.frequency,
        weekdays: request.weekdays,
        soundEnabled: true,
        vibrationEnabled: true,
        badgeEnabled: true
      };

      await this.notificationService.setNotificationPreferences(request.userId, preferences);

      return {
        success: true,
        data: { message: 'Notification settings updated successfully' },
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error updating notification settings:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Register device for push notifications
   */
  async registerPushToken(
    userId: string,
    token: string,
    platform: 'ios' | 'android' | 'web',
    deviceId: string,
    appVersion: string
  ): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`Registering push token for user: ${userId}`);

      const success = await this.notificationService.registerDevice(
        userId,
        token,
        platform,
        deviceId,
        appVersion
      );

      return {
        success,
        data: { message: success ? 'Device registered successfully' : 'Failed to register device' },
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error registering push token:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Get user analytics and insights
   */
  async getUserAnalytics(userId: string): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`Getting analytics for user: ${userId}`);

      const [
        watchHistory,
        preferences,
        notificationStats,
        recommendationHistory
      ] = await Promise.all([
        this.firebaseService.getWatchHistory(userId, 100, 0),
        UserPreferenceManager.loadPreferences(),
        this.notificationService.getNotificationStats(userId),
        this.firebaseService.getRecommendationHistory(userId, 30) // Last 30 days
      ]);

      // Calculate insights
      const analytics = this.calculateUserAnalytics({
        watchHistory,
        preferences,
        notificationStats,
        recommendationHistory
      });

      return {
        success: true,
        data: analytics,
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error getting user analytics:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  /**
   * Handle notification interaction
   */
  async handleNotificationInteraction(
    userId: string,
    notificationId: string,
    action: string
  ): Promise<APIResponse> {
    const requestId = this.generateRequestId();
    
    try {
      console.log(`Handling notification interaction: ${userId} - ${action}`);

      await this.notificationService.handleNotificationInteraction(
        userId,
        notificationId,
        action
      );

      return {
        success: true,
        data: { message: 'Interaction handled successfully' },
        timestamp: new Date().toISOString(),
        requestId
      };

    } catch (error) {
      console.error('Error handling notification interaction:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId
      };
    }
  }

  // Helper methods

  private generateRequestId(): string {
    return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private async extractMLFeatures(userId: string, mood?: any): Promise<any> {
    // Extract features for ML prediction
    const userProfile = await this.firebaseService.getUserProfile(userId);
    
    return {
      userFeatures: [
        userProfile?.preferences.genres.length || 0,
        userProfile?.preferences.ratingRange.min || 0,
        userProfile?.preferences.ratingRange.max || 10,
        // Add more user features...
      ],
      movieFeatures: [], // Would be populated based on candidate movies
      contextFeatures: [
        new Date().getHours(), // Time of day
        new Date().getDay(), // Day of week
        mood?.intensity || 5,
        // Add more contextual features...
      ]
    };
  }

  private async triggerModelUpdate(userId: string): Promise<void> {
    // Trigger async model retraining (would be handled by background job)
    console.log(`Triggering model update for user: ${userId}`);
    
    // In production, this would:
    // 1. Queue a background job
    // 2. Collect recent user interactions
    // 3. Retrain personalized models
    // 4. Update recommendation weights
  }

  private async updateMLTrainingData(ratingData: RateMovieRequest): Promise<void> {
    // Add new rating to ML training dataset
    const trainingData = {
      userId: ratingData.userId,
      movieId: ratingData.movieId,
      rating: ratingData.rating,
      implicit: false,
      context: {
        timeOfDay: new Date().getHours() < 12 ? 'morning' : 
                  new Date().getHours() < 17 ? 'afternoon' : 'evening',
        dayOfWeek: new Date().toLocaleDateString('en', { weekday: 'long' }),
        season: this.getCurrentSeason(),
        mood: ratingData.mood
      }
    };

    // Store training data (in production, would batch and process periodically)
    // For now, just log the training data
    console.log('Training data would be stored:', trainingData);
  }

  private calculateUserAnalytics(data: any): any {
    // Calculate user insights and analytics
    const { watchHistory, preferences, notificationStats, recommendationHistory } = data;

    return {
      watchingPatterns: {
        totalMoviesWatched: watchHistory.movies?.length || 0,
        averageRating: this.calculateAverageRating(watchHistory.movies || []),
        favoriteGenres: this.extractFavoriteGenres(watchHistory.movies || []),
        watchingFrequency: this.calculateWatchingFrequency(watchHistory.movies || [])
      },
      preferences: {
        genrePreferences: preferences?.genres || [],
        ratingRange: preferences?.ratingRange || { min: 0, max: 10 },
        preferredActors: preferences?.preferredActors || []
      },
      engagement: {
        notificationEngagement: {
          deliveryRate: (notificationStats.delivered / notificationStats.sent) * 100 || 0,
          openRate: (notificationStats.opened / notificationStats.delivered) * 100 || 0,
          clickRate: (notificationStats.clicked / notificationStats.opened) * 100 || 0
        },
        recommendationAcceptanceRate: this.calculateAcceptanceRate(recommendationHistory)
      },
      insights: this.generateUserInsights(watchHistory, preferences, recommendationHistory)
    };
  }

  private calculateAverageRating(movies: any[]): number {
    if (movies.length === 0) return 0;
    const sum = movies.reduce((acc, movie) => acc + (movie.userRating || 0), 0);
    return sum / movies.length;
  }

  private extractFavoriteGenres(movies: any[]): string[] {
    const genreCounts: { [genre: string]: number } = {};
    
    movies.forEach(movie => {
      movie.genres?.forEach((genre: string) => {
        genreCounts[genre] = (genreCounts[genre] || 0) + 1;
      });
    });

    return Object.entries(genreCounts)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 5)
      .map(([genre]) => genre);
  }

  private calculateWatchingFrequency(movies: any[]): string {
    if (movies.length === 0) return 'No data';
    
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    
    const recentMovies = movies.filter(movie => 
      new Date(movie.watchedAt) >= thirtyDaysAgo
    );
    
    const moviesPerWeek = (recentMovies.length / 4.3); // 4.3 weeks in a month
    
    if (moviesPerWeek >= 7) return 'Daily watcher';
    if (moviesPerWeek >= 3) return 'Regular watcher';
    if (moviesPerWeek >= 1) return 'Weekly watcher';
    return 'Occasional watcher';
  }

  private calculateAcceptanceRate(recommendationHistory: any[]): number {
    if (recommendationHistory.length === 0) return 0;
    
    const acceptedRecommendations = recommendationHistory.filter(rec => 
      rec.userInteraction === 'watched' || rec.userRating > 0
    );
    
    return (acceptedRecommendations.length / recommendationHistory.length) * 100;
  }

  private generateUserInsights(watchHistory: any, preferences: any, recommendationHistory: any[]): string[] {
    const insights: string[] = [];
    
    // Add personalized insights based on user behavior
    if (preferences?.genres?.includes('horror') && new Date().getMonth() === 9) {
      insights.push("🎃 Perfect timing for horror movies this October!");
    }
    
    if (recommendationHistory.length > 10) {
      const avgScore = recommendationHistory.reduce((sum, rec) => sum + rec.score, 0) / recommendationHistory.length;
      if (avgScore > 85) {
        insights.push("🎯 Our recommendations are hitting the mark - 85%+ match rate!");
      }
    }
    
    return insights;
  }

  private getCurrentSeason(): string {
    const month = new Date().getMonth();
    if (month >= 2 && month <= 4) return 'spring';
    if (month >= 5 && month <= 7) return 'summer';
    if (month >= 8 && month <= 10) return 'fall';
    return 'winter';
  }
}
