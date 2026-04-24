/**
 * Mood Detection and Analysis Service
 * 
 * Handles mood-based filtering and analysis for movie recommendations
 */

import { MoodEmoji, MoodInput, MoodTag } from '../types';

export class MoodDetectionService {
  /**
   * Analyze user's mood input and convert to detailed mood data
   */
  static analyzeMoodInput(
    emoji: MoodEmoji,
    intensity: number,
    seriousnessSlider: number
  ): MoodInput {
    return {
      emoji,
      intensity: Math.max(1, Math.min(10, intensity)),
      moodSlider: Math.max(1, Math.min(10, seriousnessSlider))
    };
  }
  
  /**
   * Get mood suggestions based on time of day
   */
  static getMoodSuggestions(): { emoji: MoodEmoji; label: string; description: string }[] {
    const hour = new Date().getHours();
    
    // Morning moods (6-12)
    if (hour >= 6 && hour < 12) {
      return [
        { emoji: MoodEmoji.EXCITED, label: 'Energetic', description: 'Ready for adventure!' },
        { emoji: MoodEmoji.HAPPY, label: 'Upbeat', description: 'Feeling positive and light' },
        { emoji: MoodEmoji.CURIOUS, label: 'Curious', description: 'Want to learn something new' }
      ];
    }
    
    // Afternoon moods (12-18)
    if (hour >= 12 && hour < 18) {
      return [
        { emoji: MoodEmoji.ADVENTUROUS, label: 'Adventurous', description: 'Ready for excitement' },
        { emoji: MoodEmoji.ROMANTIC, label: 'Romantic', description: 'In the mood for love' },
        { emoji: MoodEmoji.CURIOUS, label: 'Thoughtful', description: 'Want something meaningful' }
      ];
    }
    
    // Evening moods (18-24)
    if (hour >= 18) {
      return [
        { emoji: MoodEmoji.RELAXED, label: 'Chill', description: 'Want to unwind' },
        { emoji: MoodEmoji.SUSPENSE, label: 'Thrilled', description: 'Ready for suspense' },
        { emoji: MoodEmoji.INTROSPECTIVE, label: 'Reflective', description: 'In a contemplative mood' }
      ];
    }
    
    // Night moods (0-6)
    return [
      { emoji: MoodEmoji.RELAXED, label: 'Peaceful', description: 'Something calming' },
      { emoji: MoodEmoji.INTROSPECTIVE, label: 'Deep', description: 'Want to think deeply' },
      { emoji: MoodEmoji.ROMANTIC, label: 'Romantic', description: 'Perfect for a date night' }
    ];
  }
  
  /**
   * Convert mood to color theme for UI
   */
  static getMoodColor(emoji: MoodEmoji): string {
    const moodColors: Record<MoodEmoji, string> = {
      [MoodEmoji.HAPPY]: '#FFD700',      // Gold
      [MoodEmoji.EXCITED]: '#FF6B35',    // Orange Red
      [MoodEmoji.RELAXED]: '#4ECDC4',    // Turquoise
      [MoodEmoji.ROMANTIC]: '#FF69B4',   // Hot Pink
      [MoodEmoji.SUSPENSE]: '#8A2BE2',   // Blue Violet
      [MoodEmoji.INTROSPECTIVE]: '#708090', // Slate Gray
      [MoodEmoji.ADVENTUROUS]: '#32CD32', // Lime Green
      [MoodEmoji.CURIOUS]: '#FFA500'     // Orange
    };
    
    return moodColors[emoji] || '#6C7CE7';
  }
  
  /**
   * Get mood-based movie filters
   */
  static getMoodFilters(moodInput: MoodInput): {
    preferredGenres: string[];
    avoidGenres: string[];
    runtimePreference: 'short' | 'medium' | 'long' | 'any';
    intensityLevel: 'low' | 'medium' | 'high';
  } {
    const { emoji, intensity, moodSlider } = moodInput;
    
    let preferredGenres: string[] = [];
    let avoidGenres: string[] = [];
    let runtimePreference: 'short' | 'medium' | 'long' | 'any' = 'any';
    let intensityLevel: 'low' | 'medium' | 'high' = 'medium';
    
    // Set intensity level
    if (intensity <= 3) intensityLevel = 'low';
    else if (intensity >= 7) intensityLevel = 'high';
    
    // Mood-specific preferences
    switch (emoji) {
      case MoodEmoji.HAPPY:
        preferredGenres = ['comedy', 'animation', 'romance'];
        avoidGenres = ['horror', 'thriller'];
        runtimePreference = moodSlider > 7 ? 'long' : 'medium';
        break;
        
      case MoodEmoji.EXCITED:
        preferredGenres = ['action', 'adventure', 'sci-fi'];
        avoidGenres = ['drama', 'documentary'];
        runtimePreference = 'medium';
        break;
        
      case MoodEmoji.RELAXED:
        preferredGenres = ['drama', 'romance', 'comedy'];
        avoidGenres = ['horror', 'thriller', 'action'];
        runtimePreference = intensity > 5 ? 'long' : 'medium';
        break;
        
      case MoodEmoji.ROMANTIC:
        preferredGenres = ['romance', 'drama', 'comedy'];
        avoidGenres = ['horror', 'action'];
        runtimePreference = 'long';
        break;
        
      case MoodEmoji.SUSPENSE:
        preferredGenres = ['thriller', 'mystery', 'horror'];
        avoidGenres = ['comedy', 'romance'];
        runtimePreference = 'medium';
        break;
        
      case MoodEmoji.INTROSPECTIVE:
        preferredGenres = ['drama', 'documentary', 'sci-fi'];
        avoidGenres = ['comedy', 'action'];
        runtimePreference = 'long';
        break;
        
      case MoodEmoji.ADVENTUROUS:
        preferredGenres = ['adventure', 'action', 'fantasy'];
        avoidGenres = ['documentary', 'drama'];
        runtimePreference = 'medium';
        break;
        
      case MoodEmoji.CURIOUS:
        preferredGenres = ['sci-fi', 'documentary', 'mystery'];
        avoidGenres = ['horror'];
        runtimePreference = moodSlider > 6 ? 'long' : 'medium';
        break;
    }
    
    return {
      preferredGenres,
      avoidGenres,
      runtimePreference,
      intensityLevel
    };
  }
  
  /**
   * Generate mood-based recommendation explanation
   */
  static generateMoodExplanation(moodInput: MoodInput, movieTitle: string): string {
    const { emoji, intensity } = moodInput;
    
    const explanations: Record<MoodEmoji, string[]> = {
      [MoodEmoji.HAPPY]: [
        `Perfect for lifting your spirits!`,
        `This feel-good film matches your positive energy`,
        `Great choice for when you're feeling upbeat`
      ],
      [MoodEmoji.EXCITED]: [
        `This high-energy film matches your excitement!`,
        `Perfect for when you're ready for adventure`,
        `Great pick for your energetic mood`
      ],
      [MoodEmoji.RELAXED]: [
        `Perfect for a chill viewing experience`,
        `This gentle film matches your relaxed vibe`,
        `Great for unwinding and taking it easy`
      ],
      [MoodEmoji.ROMANTIC]: [
        `Perfect for your romantic mood!`,
        `This heartwarming film will melt your heart`,
        `Great choice for love and connection`
      ],
      [MoodEmoji.SUSPENSE]: [
        `This thrilling film will keep you on edge!`,
        `Perfect for when you want excitement and tension`,
        `Great pick for your suspenseful mood`
      ],
      [MoodEmoji.INTROSPECTIVE]: [
        `This thoughtful film matches your reflective mood`,
        `Perfect for deep thinking and contemplation`,
        `Great choice for meaningful viewing`
      ],
      [MoodEmoji.ADVENTUROUS]: [
        `This exciting adventure matches your bold spirit!`,
        `Perfect for when you're ready to explore`,
        `Great pick for your adventurous mood`
      ],
      [MoodEmoji.CURIOUS]: [
        `This intriguing film will satisfy your curiosity`,
        `Perfect for learning and discovery`,
        `Great choice for your inquisitive mood`
      ]
    };
    
    const moodExplanations = explanations[emoji] || explanations[MoodEmoji.HAPPY];
    const baseExplanation = moodExplanations[Math.floor(Math.random() * moodExplanations.length)];
    
    // Add intensity modifier
    if (intensity >= 8) {
      return `${baseExplanation} Your high energy calls for something truly engaging!`;
    } else if (intensity <= 3) {
      return `${baseExplanation} Something gentle for your current state of mind.`;
    }
    
    return baseExplanation;
  }
  
  /**
   * Track mood patterns over time
   */
  static async saveMoodHistory(moodInput: MoodInput): Promise<void> {
    try {
      const AsyncStorage = require('@react-native-async-storage/async-storage').default;
      const moodHistory = await AsyncStorage.getItem('mood_history');
      const history = moodHistory ? JSON.parse(moodHistory) : [];
      
      const moodEntry = {
        ...moodInput,
        timestamp: new Date().toISOString(),
        date: new Date().toISOString().split('T')[0]
      };
      
      history.push(moodEntry);
      
      // Keep only last 100 entries
      if (history.length > 100) {
        history.splice(0, history.length - 100);
      }
      
      await AsyncStorage.setItem('mood_history', JSON.stringify(history));
    } catch (error) {
      console.error('Error saving mood history:', error);
    }
  }
  
  /**
   * Get mood trends and insights
   */
  static async getMoodInsights(): Promise<{
    mostCommonMood: MoodEmoji;
    averageIntensity: number;
    moodFrequency: Record<MoodEmoji, number>;
    weeklyPattern: Record<string, MoodEmoji>;
  }> {
    try {
      const AsyncStorage = require('@react-native-async-storage/async-storage').default;
      const moodHistory = await AsyncStorage.getItem('mood_history');
      const history = moodHistory ? JSON.parse(moodHistory) : [];
      
      if (history.length === 0) {
        return {
          mostCommonMood: MoodEmoji.HAPPY,
          averageIntensity: 5,
          moodFrequency: {} as Record<MoodEmoji, number>,
          weeklyPattern: {}
        };
      }
      
      // Calculate mood frequency
      const moodFrequency: Record<MoodEmoji, number> = {} as Record<MoodEmoji, number>;
      let totalIntensity = 0;
      const weeklyPattern: Record<string, MoodEmoji> = {};
      
      history.forEach((entry: any) => {
        moodFrequency[entry.emoji] = (moodFrequency[entry.emoji] || 0) + 1;
        totalIntensity += entry.intensity;
        
        const dayOfWeek = new Date(entry.timestamp).toLocaleDateString('en', { weekday: 'long' });
        weeklyPattern[dayOfWeek] = entry.emoji;
      });
      
      // Find most common mood
      const mostCommonMood = Object.entries(moodFrequency)
        .sort(([,a], [,b]) => b - a)[0][0] as MoodEmoji;
      
      return {
        mostCommonMood,
        averageIntensity: totalIntensity / history.length,
        moodFrequency,
        weeklyPattern
      };
    } catch (error) {
      console.error('Error getting mood insights:', error);
      return {
        mostCommonMood: MoodEmoji.HAPPY,
        averageIntensity: 5,
        moodFrequency: {} as Record<MoodEmoji, number>,
        weeklyPattern: {}
      };
    }
  }
}
