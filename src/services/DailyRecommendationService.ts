/**
 * Daily Recommendation Service
 * 
 * Handles the daily movie recommendation delivery system including:
 * - Scheduled recommendations
 * - Push notifications
 * - Recommendation history tracking
 * - User preference management
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Notifications from 'expo-notifications';
import Constants from 'expo-constants';
import { UpliftReelRecommendationEngine } from './RecommendationEngine';
import {
  Movie,
  UserPreferences,
  MoodInput,
  RecommendationContext,
  RecommendationResult
} from '../types';

export class DailyRecommendationService {
  private recommendationEngine: UpliftReelRecommendationEngine;
  private static instance: DailyRecommendationService;
  private isExpoGo: boolean;
  
  private constructor() {
    this.recommendationEngine = new UpliftReelRecommendationEngine();
    this.isExpoGo = Constants.appOwnership === 'expo';
    this.initializePushNotifications().catch(console.error);
  }
  
  public static getInstance(): DailyRecommendationService {
    if (!DailyRecommendationService.instance) {
      DailyRecommendationService.instance = new DailyRecommendationService();
    }
    return DailyRecommendationService.instance;
  }
  
  /**
   * Initialize push notification system
   */
  private async initializePushNotifications(): Promise<void> {
    if (this.isExpoGo) {
      console.log('🔔 Notifications are limited in Expo Go. Using in-app notifications instead.');
      return;
    }

    try {
      // Configure Expo notifications
      Notifications.setNotificationHandler({
        handleNotification: async () => ({
          shouldShowAlert: true,
          shouldPlaySound: true,
          shouldSetBadge: false,
          shouldShowBanner: true,
          shouldShowList: true,
        }),
      });

      // Request permissions
      const { status } = await Notifications.requestPermissionsAsync();
      if (status !== 'granted') {
        console.log('Notification permissions not granted');
      } else {
        console.log('✅ Push notifications initialized successfully');
      }
    } catch (error) {
      console.log('⚠️ Push notifications not available in this environment');
    }
  }
  
  /**
   * Generate today's movie recommendation
   */
  async generateDailyRecommendation(
    userPreferences: UserPreferences,
    currentMood?: MoodInput,
    movieDatabase: Movie[] = []
  ): Promise<RecommendationResult> {
    console.log('🎬 Generating daily recommendation...');
    
    // Load user's recommendation history
    const recommendationHistory = await this.getRecommendationHistory();
    const watchedMovies = await this.getWatchedMovies();
    
    // Create recommendation context
    const context: RecommendationContext = {
      userPreferences,
      currentMood,
      previousRecommendations: recommendationHistory.slice(-30), // Last 30 recommendations
      watchedMovies
    };
    
    // Get recommendation from engine
    const recommendation = this.recommendationEngine.findBestMatch(context, movieDatabase);
    
    // Save recommendation to history
    await this.saveRecommendationToHistory(recommendation);
    
    console.log('✅ Daily recommendation generated:', recommendation.movie.title);
    return recommendation;
  }
  
  /**
   * Schedule daily notification for movie recommendation
   */
  async scheduleNotification(userPreferences: UserPreferences): Promise<void> {
    if (this.isExpoGo) {
      console.log('🔔 Scheduling not available in Expo Go. Use development build for full notifications.');
      return;
    }

    try {
      const [hours, minutes] = userPreferences.notificationTime.split(':').map(Number);
      
      // Cancel existing notifications
      await Notifications.cancelAllScheduledNotificationsAsync();
      
      // Schedule daily notification
      await Notifications.scheduleNotificationAsync({
        identifier: 'daily-movie-recommendation',
        content: {
          title: '🎬 Your Daily Movie Awaits!',
          body: 'Discover your personalized movie recommendation for today',
          sound: true,
        },
        trigger: {
          hour: hours,
          minute: minutes,
          repeats: true,
        } as any, // Type workaround for Expo notifications
      });
      
      console.log(`📅 Daily notification scheduled for ${userPreferences.notificationTime}`);
    } catch (error) {
      console.log('⚠️ Notification scheduling not available in this environment');
    }
  }
  
  /**
   * Send immediate recommendation notification
   */
  async sendRecommendationNotification(recommendation: RecommendationResult): Promise<void> {
    if (this.isExpoGo) {
      console.log('🎬 New recommendation ready!', recommendation.movie.title);
      console.log('⚠️ Push notifications limited in Expo Go. Check the app for your recommendation!');
      return;
    }

    try {
      const { movie, explanation } = recommendation;
      
      await Notifications.scheduleNotificationAsync({
        identifier: 'movie-recommendation',
        content: {
          title: `🎬 ${movie.title}`,
          body: `${movie.imdbRating}⭐ • ${movie.runtime}min • ${explanation}`,
          data: {
            movieId: movie.id,
            recommendation: recommendation,
            trailerUrl: movie.trailerUrl,
          },
          sound: true,
        },
        trigger: null, // Send immediately
      });
      
      console.log('📱 Recommendation notification sent!');
    } catch (error) {
      console.log('⚠️ Push notification not available, but recommendation is ready in the app!');
    }
  }
  
  /**
   * Get next notification date based on user's preferred time
   */
  private getNextNotificationDate(hours: number, minutes: number): Date {
    const now = new Date();
    const notificationTime = new Date();
    
    notificationTime.setHours(hours, minutes, 0, 0);
    
    // If the time has already passed today, schedule for tomorrow
    if (notificationTime <= now) {
      notificationTime.setDate(notificationTime.getDate() + 1);
    }
    
    return notificationTime;
  }
  
  /**
   * Save recommendation to user's history
   */
  private async saveRecommendationToHistory(recommendation: RecommendationResult): Promise<void> {
    try {
      const history = await this.getRecommendationHistory();
      const newEntry = {
        movieId: recommendation.movie.id,
        date: new Date().toISOString(),
        matchScore: recommendation.matchScore,
        isAlternative: recommendation.isAlternative
      };
      
      history.push(newEntry.movieId);
      
      await AsyncStorage.setItem(
        'recommendation_history',
        JSON.stringify(history)
      );
      
      await AsyncStorage.setItem(
        `recommendation_${recommendation.movie.id}`,
        JSON.stringify(newEntry)
      );
      
    } catch (error) {
      console.error('Error saving recommendation to history:', error);
    }
  }
  
  /**
   * Get user's recommendation history
   */
  private async getRecommendationHistory(): Promise<string[]> {
    try {
      const history = await AsyncStorage.getItem('recommendation_history');
      return history ? JSON.parse(history) : [];
    } catch (error) {
      console.error('Error loading recommendation history:', error);
      return [];
    }
  }
  
  /**
   * Get user's watched movies list
   */
  private async getWatchedMovies(): Promise<string[]> {
    try {
      const watchedMovies = await AsyncStorage.getItem('watched_movies');
      return watchedMovies ? JSON.parse(watchedMovies) : [];
    } catch (error) {
      console.error('Error loading watched movies:', error);
      return [];
    }
  }
  
  /**
   * Mark a movie as watched
   */
  async markMovieAsWatched(movieId: string): Promise<void> {
    try {
      const watchedMovies = await this.getWatchedMovies();
      
      if (!watchedMovies.includes(movieId)) {
        watchedMovies.push(movieId);
        await AsyncStorage.setItem('watched_movies', JSON.stringify(watchedMovies));
        console.log(`✅ Movie ${movieId} marked as watched`);
      }
    } catch (error) {
      console.error('Error marking movie as watched:', error);
    }
  }
  
  /**
   * Get today's recommendation if already generated
   */
  async getTodaysRecommendation(): Promise<RecommendationResult | null> {
    try {
      const today = new Date().toISOString().split('T')[0];
      const todaysRecommendation = await AsyncStorage.getItem(`daily_recommendation_${today}`);
      
      return todaysRecommendation ? JSON.parse(todaysRecommendation) : null;
    } catch (error) {
      console.error('Error loading today\'s recommendation:', error);
      return null;
    }
  }
  
  /**
   * Save today's recommendation
   */
  async saveTodaysRecommendation(recommendation: RecommendationResult): Promise<void> {
    try {
      const today = new Date().toISOString().split('T')[0];
      await AsyncStorage.setItem(
        `daily_recommendation_${today}`,
        JSON.stringify(recommendation)
      );
    } catch (error) {
      console.error('Error saving today\'s recommendation:', error);
    }
  }
  
  /**
   * Clear old recommendations (keep last 30 days)
   */
  async cleanupOldRecommendations(): Promise<void> {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      const allKeys = await AsyncStorage.getAllKeys();
      const oldRecommendationKeys = allKeys.filter(key => {
        if (key.startsWith('daily_recommendation_')) {
          const dateStr = key.replace('daily_recommendation_', '');
          const date = new Date(dateStr);
          return date < thirtyDaysAgo;
        }
        return false;
      });
      
      if (oldRecommendationKeys.length > 0) {
        await AsyncStorage.multiRemove(oldRecommendationKeys);
        console.log(`🧹 Cleaned up ${oldRecommendationKeys.length} old recommendations`);
      }
    } catch (error) {
      console.error('Error cleaning up old recommendations:', error);
    }
  }
  
  /**
   * Get recommendation statistics
   */
  async getRecommendationStats(): Promise<{
    totalRecommendations: number;
    watchedCount: number;
    averageMatchScore: number;
    alternativeCount: number;
  }> {
    try {
      const history = await this.getRecommendationHistory();
      const watchedMovies = await this.getWatchedMovies();
      
      let totalMatchScore = 0;
      let alternativeCount = 0;
      
      for (const movieId of history) {
        const recommendationData = await AsyncStorage.getItem(`recommendation_${movieId}`);
        if (recommendationData) {
          const data = JSON.parse(recommendationData);
          totalMatchScore += data.matchScore || 0;
          if (data.isAlternative) alternativeCount++;
        }
      }
      
      return {
        totalRecommendations: history.length,
        watchedCount: watchedMovies.length,
        averageMatchScore: history.length > 0 ? totalMatchScore / history.length : 0,
        alternativeCount
      };
    } catch (error) {
      console.error('Error calculating recommendation stats:', error);
      return {
        totalRecommendations: 0,
        watchedCount: 0,
        averageMatchScore: 0,
        alternativeCount: 0
      };
    }
  }
}
