/**
 * Notification Service
 * 
 * Handles push notifications for daily movie recommendations
 * Supports both iOS and Android platforms
 * Manages notification scheduling, delivery, and user preferences
 */

interface NotificationPreferences {
  enabled: boolean;
  time: string; // Format: "HH:mm" (24-hour)
  timezone: string;
  frequency: 'daily' | 'weekly' | 'custom';
  weekdays?: number[]; // 0-6 (Sunday-Saturday)
  customDays?: string[]; // For custom frequency
  soundEnabled: boolean;
  vibrationEnabled: boolean;
  badgeEnabled: boolean;
}

interface NotificationPayload {
  title: string;
  body: string;
  data: {
    movieId: string;
    recommendationId: string;
    type: 'daily_recommendation' | 'reminder' | 'update';
    deepLink?: string;
  };
  imageUrl?: string;
  actions?: NotificationAction[];
}

interface NotificationAction {
  id: string;
  title: string;
  icon?: string;
}

interface ScheduledNotification {
  id: string;
  userId: string;
  payload: NotificationPayload;
  scheduledTime: Date;
  timezone: string;
  status: 'pending' | 'sent' | 'failed' | 'cancelled';
  attempts: number;
  lastAttempt?: Date;
  error?: string;
}

interface NotificationStats {
  sent: number;
  delivered: number;
  opened: number;
  clicked: number;
  unsubscribed: number;
  failed: number;
}

interface PushToken {
  userId: string;
  token: string;
  platform: 'ios' | 'android' | 'web';
  deviceId: string;
  appVersion: string;
  isActive: boolean;
  lastUsed: Date;
}

export class NotificationService {
  private fcm: any; // Firebase Cloud Messaging
  private apns: any; // Apple Push Notification Service
  private scheduledJobs: Map<string, any> = new Map();
  private notificationQueue: ScheduledNotification[] = [];
  private isProcessing = false;

  constructor(
    private firebaseService: any,
    private recommendationService: any
  ) {
    this.initializeServices();
    this.startNotificationProcessor();
  }

  /**
   * Initialize push notification services
   */
  private async initializeServices(): Promise<void> {
    console.log('Initializing notification services...');

    try {
      // Initialize Firebase Cloud Messaging (mock implementation)
      this.fcm = {
        send: async (message: any) => {
          console.log('FCM message sent:', message);
          return { messageId: `fcm_${Date.now()}` };
        }
      };

      // Initialize Apple Push Notification Service (mock implementation)
      this.apns = {
        send: async (notification: any) => {
          console.log('APNS notification sent:', notification);
          return { messageId: `apns_${Date.now()}` };
        }
      };

      console.log('Notification services initialized successfully');
    } catch (error) {
      console.error('Failed to initialize notification services:', error);
      throw error;
    }
  }

  /**
   * Register device for push notifications
   */
  async registerDevice(
    userId: string,
    token: string,
    platform: 'ios' | 'android' | 'web',
    deviceId: string,
    appVersion: string
  ): Promise<boolean> {
    try {
      const pushToken: PushToken = {
        userId,
        token,
        platform,
        deviceId,
        appVersion,
        isActive: true,
        lastUsed: new Date()
      };

      // Save token to database
      await this.firebaseService.savePushToken(pushToken);

      // Set up default notification preferences if not exists
      const existingPrefs = await this.getNotificationPreferences(userId);
      if (!existingPrefs) {
        await this.setNotificationPreferences(userId, this.getDefaultPreferences());
      }

      console.log(`Device registered for user ${userId}: ${token}`);
      return true;
    } catch (error) {
      console.error('Failed to register device:', error);
      return false;
    }
  }

  /**
   * Unregister device from push notifications
   */
  async unregisterDevice(userId: string, deviceId: string): Promise<boolean> {
    try {
      await this.firebaseService.deactivatePushToken(userId, deviceId);
      console.log(`Device unregistered for user ${userId}: ${deviceId}`);
      return true;
    } catch (error) {
      console.error('Failed to unregister device:', error);
      return false;
    }
  }

  /**
   * Schedule daily recommendation notification
   */
  async scheduleDailyRecommendation(
    userId: string,
    movieId: string,
    recommendationId: string
  ): Promise<string> {
    try {
      // Get user's notification preferences
      const preferences = await this.getNotificationPreferences(userId);
      if (!preferences || !preferences.enabled) {
        console.log(`Notifications disabled for user ${userId}`);
        return '';
      }

      // Get movie details for notification content
      const movie = await this.firebaseService.getMovieData(movieId);
      if (!movie) {
        throw new Error('Movie not found');
      }

      // Create notification payload
      const payload = await this.createRecommendationPayload(movie, recommendationId);

      // Calculate next notification time
      const scheduledTime = this.calculateNextNotificationTime(preferences);

      // Create scheduled notification
      const notification: ScheduledNotification = {
        id: `rec_${userId}_${recommendationId}`,
        userId,
        payload,
        scheduledTime,
        timezone: preferences.timezone,
        status: 'pending',
        attempts: 0
      };

      // Add to queue
      this.notificationQueue.push(notification);

      // Save to database
      await this.firebaseService.saveScheduledNotification(notification);

      console.log(`Daily recommendation scheduled for user ${userId} at ${scheduledTime}`);
      return notification.id;
    } catch (error) {
      console.error('Failed to schedule daily recommendation:', error);
      throw error;
    }
  }

  /**
   * Send immediate notification
   */
  async sendImmediateNotification(
    userId: string,
    payload: NotificationPayload
  ): Promise<boolean> {
    try {
      // Get user's active push tokens
      const pushTokens = await this.firebaseService.getActivePushTokens(userId);
      if (pushTokens.length === 0) {
        console.log(`No active push tokens for user ${userId}`);
        return false;
      }

      let successCount = 0;

      // Send to all active devices
      for (const pushToken of pushTokens) {
        try {
          const success = await this.sendPushNotification(pushToken, payload);
          if (success) {
            successCount++;
          }
        } catch (error) {
          console.error(`Failed to send to device ${pushToken.deviceId}:`, error);
        }
      }

      // Update statistics
      await this.updateNotificationStats(userId, 'sent', successCount);

      console.log(`Sent immediate notification to ${successCount}/${pushTokens.length} devices for user ${userId}`);
      return successCount > 0;
    } catch (error) {
      console.error('Failed to send immediate notification:', error);
      return false;
    }
  }

  /**
   * Set user notification preferences
   */
  async setNotificationPreferences(
    userId: string,
    preferences: NotificationPreferences
  ): Promise<boolean> {
    try {
      await this.firebaseService.saveNotificationPreferences(userId, preferences);

      // Reschedule notifications if preferences changed
      await this.rescheduleUserNotifications(userId);

      console.log(`Notification preferences updated for user ${userId}`);
      return true;
    } catch (error) {
      console.error('Failed to update notification preferences:', error);
      return false;
    }
  }

  /**
   * Get user notification preferences
   */
  async getNotificationPreferences(userId: string): Promise<NotificationPreferences | null> {
    try {
      return await this.firebaseService.getNotificationPreferences(userId);
    } catch (error) {
      console.error('Failed to get notification preferences:', error);
      return null;
    }
  }

  /**
   * Cancel scheduled notification
   */
  async cancelNotification(notificationId: string): Promise<boolean> {
    try {
      // Remove from queue
      const index = this.notificationQueue.findIndex(n => n.id === notificationId);
      if (index !== -1) {
        this.notificationQueue.splice(index, 1);
      }

      // Update status in database
      await this.firebaseService.updateNotificationStatus(notificationId, 'cancelled');

      console.log(`Notification cancelled: ${notificationId}`);
      return true;
    } catch (error) {
      console.error('Failed to cancel notification:', error);
      return false;
    }
  }

  /**
   * Handle notification click/interaction
   */
  async handleNotificationInteraction(
    userId: string,
    notificationId: string,
    action: string
  ): Promise<void> {
    try {
      // Update click statistics
      await this.updateNotificationStats(userId, 'clicked', 1);

      // Handle specific actions
      switch (action) {
        case 'view_movie':
          await this.handleViewMovieAction(userId, notificationId);
          break;
        case 'get_another':
          await this.handleGetAnotherAction(userId);
          break;
        case 'snooze':
          await this.handleSnoozeAction(userId, notificationId);
          break;
        case 'unsubscribe':
          await this.handleUnsubscribeAction(userId);
          break;
        default:
          console.log(`Unknown notification action: ${action}`);
      }

      console.log(`Notification interaction handled: ${userId} - ${action}`);
    } catch (error) {
      console.error('Failed to handle notification interaction:', error);
    }
  }

  /**
   * Get notification statistics
   */
  async getNotificationStats(userId?: string): Promise<NotificationStats> {
    try {
      return await this.firebaseService.getNotificationStats(userId);
    } catch (error) {
      console.error('Failed to get notification stats:', error);
      return {
        sent: 0,
        delivered: 0,
        opened: 0,
        clicked: 0,
        unsubscribed: 0,
        failed: 0
      };
    }
  }

  /**
   * Process notification queue
   */
  private async startNotificationProcessor(): Promise<void> {
    console.log('Starting notification processor...');

    setInterval(async () => {
      if (this.isProcessing) return;

      this.isProcessing = true;
      try {
        await this.processNotificationQueue();
      } catch (error) {
        console.error('Notification processor error:', error);
      } finally {
        this.isProcessing = false;
      }
    }, 60000); // Process every minute
  }

  private async processNotificationQueue(): Promise<void> {
    const now = new Date();
    const readyNotifications = this.notificationQueue.filter(
      n => n.status === 'pending' && n.scheduledTime <= now
    );

    if (readyNotifications.length === 0) return;

    console.log(`Processing ${readyNotifications.length} ready notifications...`);

    for (const notification of readyNotifications) {
      try {
        const success = await this.sendImmediateNotification(
          notification.userId,
          notification.payload
        );

        // Update notification status
        notification.status = success ? 'sent' : 'failed';
        notification.attempts++;
        notification.lastAttempt = now;

        if (!success && notification.attempts < 3) {
          // Retry later
          notification.status = 'pending';
          notification.scheduledTime = new Date(now.getTime() + 15 * 60 * 1000); // 15 minutes later
        }

        // Update in database
        await this.firebaseService.updateScheduledNotification(notification);

      } catch (error) {
        console.error(`Failed to process notification ${notification.id}:`, error);
        notification.status = 'failed';
        notification.error = error instanceof Error ? error.message : String(error);
        await this.firebaseService.updateScheduledNotification(notification);
      }
    }

    // Remove processed notifications from queue
    this.notificationQueue = this.notificationQueue.filter(
      n => !readyNotifications.includes(n)
    );
  }

  private async sendPushNotification(
    pushToken: PushToken,
    payload: NotificationPayload
  ): Promise<boolean> {
    try {
      let result;

      if (pushToken.platform === 'ios') {
        // Send via APNS
        const apnsPayload = this.convertToAPNSPayload(payload);
        result = await this.apns.send({
          token: pushToken.token,
          payload: apnsPayload
        });
      } else {
        // Send via FCM (Android/Web)
        const fcmPayload = this.convertToFCMPayload(payload);
        result = await this.fcm.send({
          token: pushToken.token,
          ...fcmPayload
        });
      }

      // Update token last used
      await this.firebaseService.updatePushTokenLastUsed(pushToken.token);

      return !!result.messageId;
    } catch (error) {
      console.error('Push notification send error:', error);

      // Handle token errors (expired, invalid)
      if (this.isTokenError(error)) {
        await this.firebaseService.deactivatePushToken(pushToken.userId, pushToken.deviceId);
      }

      return false;
    }
  }

  private async createRecommendationPayload(
    movie: any,
    recommendationId: string
  ): Promise<NotificationPayload> {
    const titles = [
      `🎬 Your daily movie: "${movie.title}"`,
      `🍿 Time for today's pick: "${movie.title}"`,
      `⭐ Today's recommendation: "${movie.title}"`,
      `🎭 Your personalized pick: "${movie.title}"`
    ];

    const bodies = [
      `${movie.genres.join(', ')} • ${movie.imdbRating}⭐ • ${movie.runtime}min`,
      `A ${movie.genres[0].toLowerCase()} film rated ${movie.imdbRating}/10`,
      `Perfectly matched to your taste • ${movie.imdbRating}⭐`,
      `${movie.releaseYear} • ${movie.genres.join(' & ')} • ${movie.imdbRating}/10`
    ];

    return {
      title: titles[Math.floor(Math.random() * titles.length)],
      body: bodies[Math.floor(Math.random() * bodies.length)],
      data: {
        movieId: movie.id,
        recommendationId,
        type: 'daily_recommendation',
        deepLink: `upliftreel://movie/${movie.id}`
      },
      imageUrl: movie.posterUrl,
      actions: [
        { id: 'view_movie', title: '🎬 View Details' },
        { id: 'get_another', title: '🔄 Get Another' }
      ]
    };
  }

  private calculateNextNotificationTime(preferences: NotificationPreferences): Date {
    const now = new Date();
    const [hours, minutes] = preferences.time.split(':').map(Number);
    
    // Create next notification time
    const nextTime = new Date();
    nextTime.setHours(hours, minutes, 0, 0);
    
    // If time has passed today, schedule for tomorrow
    if (nextTime <= now) {
      nextTime.setDate(nextTime.getDate() + 1);
    }
    
    // Handle weekly frequency
    if (preferences.frequency === 'weekly' && preferences.weekdays) {
      while (!preferences.weekdays.includes(nextTime.getDay())) {
        nextTime.setDate(nextTime.getDate() + 1);
      }
    }
    
    return nextTime;
  }

  private getDefaultPreferences(): NotificationPreferences {
    return {
      enabled: true,
      time: '19:00', // 7 PM
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      frequency: 'daily',
      soundEnabled: true,
      vibrationEnabled: true,
      badgeEnabled: true
    };
  }

  private convertToAPNSPayload(payload: NotificationPayload): any {
    return {
      aps: {
        alert: {
          title: payload.title,
          body: payload.body
        },
        badge: 1,
        sound: 'default'
      },
      customData: payload.data
    };
  }

  private convertToFCMPayload(payload: NotificationPayload): any {
    return {
      notification: {
        title: payload.title,
        body: payload.body,
        image: payload.imageUrl
      },
      data: payload.data,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          color: '#FF6B35'
        }
      }
    };
  }

  private isTokenError(error: any): boolean {
    // Check for common token-related errors
    const tokenErrors = [
      'invalid-registration-token',
      'registration-token-not-registered',
      'invalid-package-name',
      'message-rate-exceeded'
    ];
    
    return tokenErrors.some(errorCode => 
      error.message?.includes(errorCode) || error.code === errorCode
    );
  }

  private async rescheduleUserNotifications(userId: string): Promise<void> {
    // Cancel existing scheduled notifications
    const existingNotifications = this.notificationQueue.filter(n => n.userId === userId);
    for (const notification of existingNotifications) {
      await this.cancelNotification(notification.id);
    }

    // Schedule new notifications based on updated preferences
    // This would typically be handled by the daily recommendation service
    console.log(`Rescheduled notifications for user ${userId}`);
  }

  private async updateNotificationStats(
    userId: string,
    metric: keyof NotificationStats,
    count: number
  ): Promise<void> {
    await this.firebaseService.updateNotificationStats(userId, metric, count);
  }

  private async handleViewMovieAction(userId: string, notificationId: string): Promise<void> {
    // Track user engagement
    await this.firebaseService.trackNotificationAction(userId, notificationId, 'view_movie');
  }

  private async handleGetAnotherAction(userId: string): Promise<void> {
    // Generate new recommendation
    await this.recommendationService.generateDailyRecommendation(userId);
  }

  private async handleSnoozeAction(userId: string, notificationId: string): Promise<void> {
    // Reschedule notification for 1 hour later
    const snoozeTime = new Date(Date.now() + 60 * 60 * 1000);
    await this.firebaseService.snoozeNotification(notificationId, snoozeTime);
  }

  private async handleUnsubscribeAction(userId: string): Promise<void> {
    // Disable notifications for user
    const preferences = await this.getNotificationPreferences(userId);
    if (preferences) {
      preferences.enabled = false;
      await this.setNotificationPreferences(userId, preferences);
    }
  }
}
