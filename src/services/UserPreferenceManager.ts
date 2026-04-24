/**
 * User Preference Manager
 * 
 * Handles all user preference operations including:
 * - Preference persistence
 * - Default configurations
 * - Preference updates and validation
 * - Export/Import functionality
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import { UserPreferences, Genre } from '../types';

export class UserPreferenceManager {
  private static readonly PREFERENCES_KEY = 'user_preferences';
  private static readonly PREFERENCES_VERSION = '1.0';
  
  /**
   * Get default user preferences
   */
  static getDefaultPreferences(): UserPreferences {
    return {
      selectedGenres: [Genre.COMEDY, Genre.DRAMA, Genre.ACTION],
      minRating: 6.0,
      maxRating: 10.0,
      preferredActors: [],
      preferredDirectors: [],
      releaseYearRange: {
        min: 1990,
        max: new Date().getFullYear()
      },
      maxRuntime: 180, // 3 hours
      excludedGenres: [],
      excludedMovies: [],
      notificationTime: '19:00' // 7 PM default
    };
  }
  
  /**
   * Load user preferences from storage
   */
  static async loadPreferences(): Promise<UserPreferences> {
    try {
      const stored = await AsyncStorage.getItem(this.PREFERENCES_KEY);
      
      if (stored) {
        const parsed = JSON.parse(stored);
        
        // Validate and merge with defaults for backward compatibility
        const defaults = this.getDefaultPreferences();
        const preferences = { ...defaults, ...parsed };
        
        // Validate preferences
        return this.validatePreferences(preferences);
      }
      
      // Return defaults if no stored preferences
      const defaults = this.getDefaultPreferences();
      await this.savePreferences(defaults);
      return defaults;
      
    } catch (error) {
      console.error('Error loading user preferences:', error);
      return this.getDefaultPreferences();
    }
  }
  
  /**
   * Save user preferences to storage
   */
  static async savePreferences(preferences: UserPreferences): Promise<void> {
    try {
      const validatedPreferences = this.validatePreferences(preferences);
      const dataToStore = {
        ...validatedPreferences,
        version: this.PREFERENCES_VERSION,
        lastUpdated: new Date().toISOString()
      };
      
      await AsyncStorage.setItem(this.PREFERENCES_KEY, JSON.stringify(dataToStore));
      console.log('✅ User preferences saved successfully');
    } catch (error) {
      console.error('Error saving user preferences:', error);
      throw new Error('Failed to save preferences');
    }
  }
  
  /**
   * Validate user preferences
   */
  private static validatePreferences(preferences: UserPreferences): UserPreferences {
    const validated = { ...preferences };
    
    // Validate genres
    if (!validated.selectedGenres || validated.selectedGenres.length === 0) {
      validated.selectedGenres = [Genre.COMEDY, Genre.DRAMA];
    }
    
    // Validate ratings
    validated.minRating = Math.max(1, Math.min(10, validated.minRating || 1));
    validated.maxRating = Math.max(validated.minRating, Math.min(10, validated.maxRating || 10));
    
    // Validate release year range
    const currentYear = new Date().getFullYear();
    if (validated.releaseYearRange) {
      validated.releaseYearRange.min = Math.max(1900, Math.min(currentYear, validated.releaseYearRange.min));
      validated.releaseYearRange.max = Math.max(validated.releaseYearRange.min, Math.min(currentYear, validated.releaseYearRange.max));
    }
    
    // Validate runtime
    if (validated.maxRuntime) {
      validated.maxRuntime = Math.max(30, Math.min(300, validated.maxRuntime)); // 30min to 5 hours
    }
    
    // Validate notification time
    if (!validated.notificationTime || !this.isValidTime(validated.notificationTime)) {
      validated.notificationTime = '19:00';
    }
    
    // Ensure arrays are initialized
    validated.preferredActors = validated.preferredActors || [];
    validated.preferredDirectors = validated.preferredDirectors || [];
    validated.excludedGenres = validated.excludedGenres || [];
    validated.excludedMovies = validated.excludedMovies || [];
    
    return validated;
  }
  
  /**
   * Validate time format (HH:MM)
   */
  private static isValidTime(time: string): boolean {
    const timeRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
    return timeRegex.test(time);
  }
  
  /**
   * Update specific preference section
   */
  static async updatePreferences(updates: Partial<UserPreferences>): Promise<UserPreferences> {
    const currentPreferences = await this.loadPreferences();
    const updatedPreferences = { ...currentPreferences, ...updates };
    
    await this.savePreferences(updatedPreferences);
    return updatedPreferences;
  }
  
  /**
   * Add preferred actor
   */
  static async addPreferredActor(actorName: string): Promise<void> {
    const preferences = await this.loadPreferences();
    
    if (!preferences.preferredActors?.includes(actorName)) {
      preferences.preferredActors = preferences.preferredActors || [];
      preferences.preferredActors.push(actorName);
      await this.savePreferences(preferences);
    }
  }
  
  /**
   * Remove preferred actor
   */
  static async removePreferredActor(actorName: string): Promise<void> {
    const preferences = await this.loadPreferences();
    preferences.preferredActors = preferences.preferredActors?.filter(actor => actor !== actorName) || [];
    await this.savePreferences(preferences);
  }
  
  /**
   * Add preferred director
   */
  static async addPreferredDirector(directorName: string): Promise<void> {
    const preferences = await this.loadPreferences();
    
    if (!preferences.preferredDirectors?.includes(directorName)) {
      preferences.preferredDirectors = preferences.preferredDirectors || [];
      preferences.preferredDirectors.push(directorName);
      await this.savePreferences(preferences);
    }
  }
  
  /**
   * Remove preferred director
   */
  static async removePreferredDirector(directorName: string): Promise<void> {
    const preferences = await this.loadPreferences();
    if (preferences.preferredDirectors) {
      preferences.preferredDirectors = preferences.preferredDirectors.filter(director => director !== directorName);
      await this.savePreferences(preferences);
    }
  }
  
  /**
   * Add excluded movie
   */
  static async addExcludedMovie(movieId: string): Promise<void> {
    const preferences = await this.loadPreferences();
    
    if (!preferences.excludedMovies?.includes(movieId)) {
      preferences.excludedMovies = preferences.excludedMovies || [];
      preferences.excludedMovies.push(movieId);
      await this.savePreferences(preferences);
    }
  }
  
  /**
   * Remove excluded movie
   */
  static async removeExcludedMovie(movieId: string): Promise<void> {
    const preferences = await this.loadPreferences();
    if (preferences.excludedMovies) {
      preferences.excludedMovies = preferences.excludedMovies.filter(id => id !== movieId);
      await this.savePreferences(preferences);
    }
  }
  
  /**
   * Toggle genre selection
   */
  static async toggleGenre(genre: Genre): Promise<void> {
    const preferences = await this.loadPreferences();
    
    if (preferences.selectedGenres.includes(genre)) {
      // Don't allow removing all genres
      if (preferences.selectedGenres.length > 1) {
        preferences.selectedGenres = preferences.selectedGenres.filter(g => g !== genre);
      }
    } else {
      preferences.selectedGenres.push(genre);
    }
    
    await this.savePreferences(preferences);
  }
  
  /**
   * Set rating range
   */
  static async setRatingRange(minRating: number, maxRating: number): Promise<void> {
    const preferences = await this.loadPreferences();
    
    preferences.minRating = Math.max(1, Math.min(10, minRating));
    preferences.maxRating = Math.max(preferences.minRating, Math.min(10, maxRating));
    
    await this.savePreferences(preferences);
  }
  
  /**
   * Set release year range
   */
  static async setReleaseYearRange(minYear: number, maxYear: number): Promise<void> {
    const preferences = await this.loadPreferences();
    const currentYear = new Date().getFullYear();
    
    preferences.releaseYearRange = {
      min: Math.max(1900, Math.min(currentYear, minYear)),
      max: Math.max(minYear, Math.min(currentYear, maxYear))
    };
    
    await this.savePreferences(preferences);
  }
  
  /**
   * Set notification time
   */
  static async setNotificationTime(time: string): Promise<void> {
    if (!this.isValidTime(time)) {
      throw new Error('Invalid time format. Use HH:MM format.');
    }
    
    const preferences = await this.loadPreferences();
    preferences.notificationTime = time;
    await this.savePreferences(preferences);
  }
  
  /**
   * Export preferences for backup
   */
  static async exportPreferences(): Promise<string> {
    const preferences = await this.loadPreferences();
    const exportData = {
      ...preferences,
      exportVersion: this.PREFERENCES_VERSION,
      exportDate: new Date().toISOString(),
      appName: 'UpliftReel'
    };
    
    return JSON.stringify(exportData, null, 2);
  }
  
  /**
   * Import preferences from backup
   */
  static async importPreferences(importData: string): Promise<void> {
    try {
      const parsed = JSON.parse(importData);
      
      // Validate import data
      if (parsed.appName !== 'UpliftReel') {
        throw new Error('Invalid backup file - not from UpliftReel');
      }
      
      // Extract preferences (remove export metadata)
      const { exportVersion, exportDate, appName, ...preferences } = parsed;
      
      // Validate and save
      const validatedPreferences = this.validatePreferences(preferences);
      await this.savePreferences(validatedPreferences);
      
      console.log('✅ Preferences imported successfully');
    } catch (error) {
      console.error('Error importing preferences:', error);
      throw new Error('Failed to import preferences - invalid format');
    }
  }
  
  /**
   * Reset preferences to defaults
   */
  static async resetToDefaults(): Promise<void> {
    const defaultPreferences = this.getDefaultPreferences();
    await this.savePreferences(defaultPreferences);
    console.log('✅ Preferences reset to defaults');
  }
  
  /**
   * Get preference summary for display
   */
  static async getPreferenceSummary(): Promise<{
    genreCount: number;
    ratingRange: string;
    yearRange: string;
    hasActorPreferences: boolean;
    hasDirectorPreferences: boolean;
    notificationTime: string;
    maxRuntime: string;
  }> {
    const preferences = await this.loadPreferences();
    
    return {
      genreCount: preferences.selectedGenres.length,
      ratingRange: `${preferences.minRating} - ${preferences.maxRating}`,
      yearRange: preferences.releaseYearRange 
        ? `${preferences.releaseYearRange.min} - ${preferences.releaseYearRange.max}`
        : 'All years',
      hasActorPreferences: (preferences.preferredActors?.length || 0) > 0,
      hasDirectorPreferences: (preferences.preferredDirectors?.length || 0) > 0,
      notificationTime: preferences.notificationTime,
      maxRuntime: preferences.maxRuntime 
        ? `${Math.floor(preferences.maxRuntime / 60)}h ${preferences.maxRuntime % 60}m`
        : 'No limit'
    };
  }
  
  /**
   * Get recommendation constraints for display
   */
  static async getRecommendationConstraints(): Promise<{
    totalMoviesFiltered: number;
    activeFilters: string[];
    restrictiveness: 'low' | 'medium' | 'high';
  }> {
    const preferences = await this.loadPreferences();
    const activeFilters: string[] = [];
    let restrictiveness: 'low' | 'medium' | 'high' = 'low';
    
    // Count active filters
    if (preferences.selectedGenres.length < 5) {
      activeFilters.push(`${preferences.selectedGenres.length} genres selected`);
    }
    
    if (preferences.minRating > 6) {
      activeFilters.push(`High rating requirement (${preferences.minRating}+)`);
    }
    
    if (preferences.releaseYearRange && 
        (preferences.releaseYearRange.max - preferences.releaseYearRange.min) < 20) {
      activeFilters.push('Narrow year range');
    }
    
    if (preferences.maxRuntime && preferences.maxRuntime < 120) {
      activeFilters.push('Short runtime only');
    }
    
    if (preferences.preferredActors && preferences.preferredActors.length > 0) {
      activeFilters.push(`${preferences.preferredActors.length} preferred actors`);
    }
    
    if (preferences.preferredDirectors && preferences.preferredDirectors.length > 0) {
      activeFilters.push(`${preferences.preferredDirectors.length} preferred directors`);
    }
    
    if (preferences.excludedGenres && preferences.excludedGenres.length > 0) {
      activeFilters.push(`${preferences.excludedGenres.length} excluded genres`);
    }
    
    // Determine restrictiveness
    if (activeFilters.length >= 4) {
      restrictiveness = 'high';
    } else if (activeFilters.length >= 2) {
      restrictiveness = 'medium';
    }
    
    return {
      totalMoviesFiltered: 0, // This would be calculated with actual movie database
      activeFilters,
      restrictiveness
    };
  }
}
