/**
 * Firebase Service
 * 
 * Handles user authentication, data persistence, and Firestore operations
 * Implements privacy-first data handling with user consent management
 */

interface UserProfile {
  userId: string;
  email: string;
  displayName: string;
  preferences: UserPreferences;
  privacySettings: PrivacySettings;
  createdAt: Date;
  lastActive: Date;
}

interface UserPreferences {
  genres: string[];
  ratingRange: { min: number; max: number };
  preferredActors: string[];
  preferredDirectors: string[];
  excludedGenres: string[];
  excludedMovies: string[];
  notificationTime: string;
  streamingServices: string[];
  releaseYearRange?: { min: number; max: number };
  maxRuntime?: number;
}

interface PrivacySettings {
  dataCollection: boolean;
  personalization: boolean;
  analytics: boolean;
  marketingEmails: boolean;
  dataRetentionDays: number;
}

interface WatchHistory {
  movieId: string;
  watchedAt: Date;
  rating?: number;
  review?: string;
  moodAtTime?: string;
}

interface Recommendation {
  id: string;
  movieId: string;
  userId: string;
  date: string;
  score: number;
  reason: string;
  algorithm: string;
  viewed: boolean;
  clicked: boolean;
  feedback?: 'liked' | 'disliked' | 'not_interested';
  createdAt: Date;
}

interface AnalyticsEvent {
  userId: string;
  eventType: string;
  eventData: any;
  timestamp: Date;
  sessionId: string;
  appVersion: string;
  platform: string;
}

export class FirebaseService {
  private db: any; // Firestore instance
  private auth: any; // Firebase Auth instance
  private analytics: any; // Firebase Analytics instance

  constructor() {
    this.initializeFirebase();
  }

  private initializeFirebase(): void {
    // Initialize Firebase SDK
    // This would normally import and configure Firebase
    console.log('Firebase initialized');
  }

  // User Management

  /**
   * Create user profile with privacy settings
   */
  async createUserProfile(
    userId: string,
    email: string,
    displayName: string,
    initialPreferences?: Partial<UserPreferences>
  ): Promise<UserProfile> {
    const defaultPreferences: UserPreferences = {
      genres: ['comedy', 'drama', 'action'],
      ratingRange: { min: 6.0, max: 10.0 },
      preferredActors: [],
      preferredDirectors: [],
      excludedGenres: [],
      excludedMovies: [],
      notificationTime: '19:00',
      streamingServices: [],
      releaseYearRange: { min: 1990, max: new Date().getFullYear() },
      maxRuntime: 180
    };

    const defaultPrivacySettings: PrivacySettings = {
      dataCollection: true,
      personalization: true,
      analytics: false,
      marketingEmails: false,
      dataRetentionDays: 365
    };

    const userProfile: UserProfile = {
      userId,
      email,
      displayName,
      preferences: { ...defaultPreferences, ...initialPreferences },
      privacySettings: defaultPrivacySettings,
      createdAt: new Date(),
      lastActive: new Date()
    };

    try {
      // Store in Firestore
      await this.db.collection('users').doc(userId).set(userProfile);
      
      // Create user profile document
      await this.db.collection('userProfiles').doc(userId).set({
        userId,
        preferences: userProfile.preferences,
        watchHistory: [],
        recommendations: [],
        createdAt: new Date(),
        lastUpdated: new Date()
      });

      console.log(`User profile created for ${userId}`);
      return userProfile;
    } catch (error) {
      console.error('Error creating user profile:', error);
      throw new Error('Failed to create user profile');
    }
  }

  /**
   * Get user profile
   */
  async getUserProfile(userId: string): Promise<UserProfile | null> {
    try {
      const doc = await this.db.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }

      const data = doc.data();
      return {
        ...data,
        createdAt: data.createdAt.toDate(),
        lastActive: data.lastActive.toDate()
      };
    } catch (error) {
      console.error('Error fetching user profile:', error);
      return null;
    }
  }

  /**
   * Update user preferences
   */
  async updateUserPreferences(
    userId: string,
    preferences: Partial<UserPreferences>
  ): Promise<void> {
    try {
      // Check user consent for data updates
      const userProfile = await this.getUserProfile(userId);
      if (!userProfile?.privacySettings.dataCollection) {
        throw new Error('User has not consented to data collection');
      }

      // Update user document
      await this.db.collection('users').doc(userId).update({
        preferences: preferences,
        lastActive: new Date()
      });

      // Update user profile document
      await this.db.collection('userProfiles').doc(userId).update({
        preferences: preferences,
        lastUpdated: new Date()
      });

      console.log(`Preferences updated for user ${userId}`);
    } catch (error) {
      console.error('Error updating user preferences:', error);
      throw new Error('Failed to update user preferences');
    }
  }

  /**
   * Update privacy settings
   */
  async updatePrivacySettings(
    userId: string,
    privacySettings: Partial<PrivacySettings>
  ): Promise<void> {
    try {
      await this.db.collection('users').doc(userId).update({
        privacySettings: privacySettings,
        lastActive: new Date()
      });

      // If user opts out of data collection, anonymize existing data
      if (privacySettings.dataCollection === false) {
        await this.anonymizeUserData(userId);
      }

      console.log(`Privacy settings updated for user ${userId}`);
    } catch (error) {
      console.error('Error updating privacy settings:', error);
      throw new Error('Failed to update privacy settings');
    }
  }

  // Watch History Management

  /**
   * Add movie to watch history
   */
  async addToWatchHistory(
    userId: string,
    watchEntry: Omit<WatchHistory, 'watchedAt'>
  ): Promise<void> {
    try {
      // Check user consent
      const userProfile = await this.getUserProfile(userId);
      if (!userProfile?.privacySettings.dataCollection) {
        return; // Silently fail if user hasn't consented
      }

      const watchHistoryEntry: WatchHistory = {
        ...watchEntry,
        watchedAt: new Date()
      };

      // Add to user's watch history subcollection
      await this.db
        .collection('userProfiles')
        .doc(userId)
        .collection('watchHistory')
        .add(watchHistoryEntry);

      // Update last active timestamp
      await this.db.collection('users').doc(userId).update({
        lastActive: new Date()
      });

      console.log(`Added movie ${watchEntry.movieId} to watch history for user ${userId}`);
    } catch (error) {
      console.error('Error adding to watch history:', error);
      throw new Error('Failed to add to watch history');
    }
  }

  /**
   * Get user's watch history
   */
  async getWatchHistory(
    userId: string,
    limit: number = 50,
    offset: number = 0
  ): Promise<WatchHistory[]> {
    try {
      const snapshot = await this.db
        .collection('userProfiles')
        .doc(userId)
        .collection('watchHistory')
        .orderBy('watchedAt', 'desc')
        .limit(limit)
        .offset(offset)
        .get();

      return snapshot.docs.map((doc: any) => ({
        ...doc.data(),
        watchedAt: doc.data().watchedAt.toDate()
      }));
    } catch (error) {
      console.error('Error fetching watch history:', error);
      return [];
    }
  }

  // Recommendation Management

  /**
   * Save recommendation
   */
  async saveRecommendation(recommendation: Recommendation): Promise<void> {
    try {
      // Check user consent
      const userProfile = await this.getUserProfile(recommendation.userId);
      if (!userProfile?.privacySettings.personalization) {
        return; // Don't save if user hasn't consented to personalization
      }

      await this.db
        .collection('recommendations')
        .doc(recommendation.id)
        .set({
          ...recommendation,
          createdAt: new Date()
        });

      console.log(`Recommendation ${recommendation.id} saved for user ${recommendation.userId}`);
    } catch (error) {
      console.error('Error saving recommendation:', error);
      throw new Error('Failed to save recommendation');
    }
  }

  /**
   * Get user's recommendation history
   */
  async getRecommendationHistory(
    userId: string,
    limit: number = 30
  ): Promise<Recommendation[]> {
    try {
      const snapshot = await this.db
        .collection('recommendations')
        .where('userId', '==', userId)
        .orderBy('createdAt', 'desc')
        .limit(limit)
        .get();

      return snapshot.docs.map((doc: any) => ({
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate()
      }));
    } catch (error) {
      console.error('Error fetching recommendation history:', error);
      return [];
    }
  }

  /**
   * Update recommendation feedback
   */
  async updateRecommendationFeedback(
    recommendationId: string,
    feedback: 'liked' | 'disliked' | 'not_interested',
    userId: string
  ): Promise<void> {
    try {
      // Check user consent
      const userProfile = await this.getUserProfile(userId);
      if (!userProfile?.privacySettings.personalization) {
        return;
      }

      await this.db
        .collection('recommendations')
        .doc(recommendationId)
        .update({
          feedback,
          feedbackAt: new Date()
        });

      console.log(`Feedback "${feedback}" recorded for recommendation ${recommendationId}`);
    } catch (error) {
      console.error('Error updating recommendation feedback:', error);
      throw new Error('Failed to update recommendation feedback');
    }
  }

  // Movie Data Management

  /**
   * Store/update movie data
   */
  async storeMovieData(movie: any): Promise<void> {
    try {
      const movieData = {
        ...movie,
        lastUpdated: new Date()
      };

      await this.db
        .collection('movies')
        .doc(movie.id.toString())
        .set(movieData, { merge: true });

      console.log(`Movie data stored for ${movie.title} (${movie.id})`);
    } catch (error) {
      console.error('Error storing movie data:', error);
      throw new Error('Failed to store movie data');
    }
  }

  /**
   * Get movie data
   */
  async getMovieData(movieId: string): Promise<any | null> {
    try {
      const doc = await this.db.collection('movies').doc(movieId).get();
      
      if (!doc.exists) {
        return null;
      }

      const data = doc.data();
      return {
        ...data,
        lastUpdated: data.lastUpdated.toDate()
      };
    } catch (error) {
      console.error('Error fetching movie data:', error);
      return null;
    }
  }

  /**
   * Search movies by criteria
   */
  async searchMovies(criteria: {
    genres?: string[];
    minRating?: number;
    maxRating?: number;
    releaseYearMin?: number;
    releaseYearMax?: number;
    limit?: number;
  }): Promise<any[]> {
    try {
      let query = this.db.collection('movies');

      // Apply filters
      if (criteria.genres && criteria.genres.length > 0) {
        query = query.where('genres', 'array-contains-any', criteria.genres);
      }

      if (criteria.minRating) {
        query = query.where('imdbRating', '>=', criteria.minRating);
      }

      if (criteria.maxRating) {
        query = query.where('imdbRating', '<=', criteria.maxRating);
      }

      if (criteria.releaseYearMin) {
        query = query.where('releaseYear', '>=', criteria.releaseYearMin);
      }

      if (criteria.releaseYearMax) {
        query = query.where('releaseYear', '<=', criteria.releaseYearMax);
      }

      // Apply limit
      query = query.limit(criteria.limit || 50);

      const snapshot = await query.get();
      return snapshot.docs.map((doc: any) => ({
        ...doc.data(),
        lastUpdated: doc.data().lastUpdated.toDate()
      }));
    } catch (error) {
      console.error('Error searching movies:', error);
      return [];
    }
  }

  // Analytics

  /**
   * Track analytics event
   */
  async trackEvent(event: Omit<AnalyticsEvent, 'timestamp'>): Promise<void> {
    try {
      // Check user consent
      const userProfile = await this.getUserProfile(event.userId);
      if (!userProfile?.privacySettings.analytics) {
        return; // Don't track if user hasn't consented
      }

      const analyticsEvent: AnalyticsEvent = {
        ...event,
        timestamp: new Date()
      };

      await this.db.collection('analytics').add(analyticsEvent);
    } catch (error) {
      console.error('Error tracking analytics event:', error);
    }
  }

  // Privacy & GDPR Compliance

  /**
   * Export user data (GDPR compliance)
   */
  async exportUserData(userId: string): Promise<any> {
    try {
      const userData = {
        profile: await this.getUserProfile(userId),
        watchHistory: await this.getWatchHistory(userId, 1000),
        recommendations: await this.getRecommendationHistory(userId, 1000)
      };

      return {
        exportDate: new Date(),
        userId,
        data: userData
      };
    } catch (error) {
      console.error('Error exporting user data:', error);
      throw new Error('Failed to export user data');
    }
  }

  /**
   * Delete user data (GDPR compliance)
   */
  async deleteUserData(userId: string): Promise<void> {
    try {
      const batch = this.db.batch();

      // Delete user profile
      batch.delete(this.db.collection('users').doc(userId));
      batch.delete(this.db.collection('userProfiles').doc(userId));

      // Delete watch history
      const watchHistorySnapshot = await this.db
        .collection('userProfiles')
        .doc(userId)
        .collection('watchHistory')
        .get();
      
      watchHistorySnapshot.docs.forEach((doc: any) => {
        batch.delete(doc.ref);
      });

      // Delete recommendations
      const recommendationsSnapshot = await this.db
        .collection('recommendations')
        .where('userId', '==', userId)
        .get();
      
      recommendationsSnapshot.docs.forEach((doc: any) => {
        batch.delete(doc.ref);
      });

      // Delete analytics events
      const analyticsSnapshot = await this.db
        .collection('analytics')
        .where('userId', '==', userId)
        .get();
      
      analyticsSnapshot.docs.forEach((doc: any) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`All data deleted for user ${userId}`);
    } catch (error) {
      console.error('Error deleting user data:', error);
      throw new Error('Failed to delete user data');
    }
  }

  /**
   * Anonymize user data
   */
  private async anonymizeUserData(userId: string): Promise<void> {
    try {
      // Replace personal identifiers with anonymous IDs
      const anonymousId = `anon_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

      // Update recommendations to use anonymous ID
      const recommendationsSnapshot = await this.db
        .collection('recommendations')
        .where('userId', '==', userId)
        .get();

      const batch = this.db.batch();
      
      recommendationsSnapshot.docs.forEach((doc: any) => {
        batch.update(doc.ref, { userId: anonymousId });
      });

      // Update analytics events
      const analyticsSnapshot = await this.db
        .collection('analytics')
        .where('userId', '==', userId)
        .get();
      
      analyticsSnapshot.docs.forEach((doc: any) => {
        batch.update(doc.ref, { userId: anonymousId });
      });

      await batch.commit();
      console.log(`Data anonymized for user ${userId} -> ${anonymousId}`);
    } catch (error) {
      console.error('Error anonymizing user data:', error);
      throw new Error('Failed to anonymize user data');
    }
  }

  /**
   * Clean up expired data based on retention policies
   */
  async cleanupExpiredData(): Promise<void> {
    try {
      const batch = this.db.batch();
      
      // Get users with data retention policies
      const usersSnapshot = await this.db.collection('users').get();
      
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const retentionDays = userData.privacySettings?.dataRetentionDays || 365;
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

        // Clean up old analytics events
        const oldAnalyticsSnapshot = await this.db
          .collection('analytics')
          .where('userId', '==', userDoc.id)
          .where('timestamp', '<', cutoffDate)
          .get();

        oldAnalyticsSnapshot.docs.forEach((doc: any) => {
          batch.delete(doc.ref);
        });

        // Clean up old recommendations
        const oldRecommendationsSnapshot = await this.db
          .collection('recommendations')
          .where('userId', '==', userDoc.id)
          .where('createdAt', '<', cutoffDate)
          .get();

        oldRecommendationsSnapshot.docs.forEach((doc: any) => {
          batch.delete(doc.ref);
        });
      }

      await batch.commit();
      console.log('Expired data cleanup completed');
    } catch (error) {
      console.error('Error during data cleanup:', error);
    }
  }

  // Health & Monitoring

  /**
   * Get database health status
   */
  async getHealthStatus(): Promise<any> {
    try {
      // Test database connectivity
      const testDoc = await this.db.collection('health').doc('test').get();
      
      return {
        status: 'healthy',
        timestamp: new Date(),
        connectivity: 'ok'
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        timestamp: new Date(),
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }
}
