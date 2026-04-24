/**
 * App Context - Global State Management
 * 
 * Provides centralized state management for:
 * - User preferences
 * - Current mood
 * - Today's recommendation
 * - App settings
 */

import React, { createContext, useContext, useReducer, useEffect, ReactNode } from 'react';
import { UserPreferences, MoodInput, RecommendationResult, Movie, Genre, MoodTag } from '../types';
import { UserPreferenceManager } from '../services/UserPreferenceManager';
import { DailyRecommendationService } from '../services/DailyRecommendationService';

// State interface
interface AppState {
  userPreferences: UserPreferences | null;
  currentMood: MoodInput | null;
  todaysRecommendation: RecommendationResult | null;
  isLoading: boolean;
  error: string | null;
  movieDatabase: Movie[];
  lastRecommendationDate: string | null;
}

// Action types
type AppAction =
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string | null }
  | { type: 'SET_USER_PREFERENCES'; payload: UserPreferences }
  | { type: 'SET_CURRENT_MOOD'; payload: MoodInput | null }
  | { type: 'SET_TODAYS_RECOMMENDATION'; payload: RecommendationResult | null }
  | { type: 'SET_MOVIE_DATABASE'; payload: Movie[] }
  | { type: 'SET_LAST_RECOMMENDATION_DATE'; payload: string | null };

// Initial state
const initialState: AppState = {
  userPreferences: null,
  currentMood: null,
  todaysRecommendation: null,
  isLoading: true,
  error: null,
  movieDatabase: [],
  lastRecommendationDate: null,
};

// Reducer
const appReducer = (state: AppState, action: AppAction): AppState => {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, isLoading: action.payload };
    case 'SET_ERROR':
      return { ...state, error: action.payload };
    case 'SET_USER_PREFERENCES':
      return { ...state, userPreferences: action.payload };
    case 'SET_CURRENT_MOOD':
      return { ...state, currentMood: action.payload };
    case 'SET_TODAYS_RECOMMENDATION':
      return { ...state, todaysRecommendation: action.payload };
    case 'SET_MOVIE_DATABASE':
      return { ...state, movieDatabase: action.payload };
    case 'SET_LAST_RECOMMENDATION_DATE':
      return { ...state, lastRecommendationDate: action.payload };
    default:
      return state;
  }
};

// Context interface
interface AppContextType {
  state: AppState;
  // User Preferences
  updateUserPreferences: (preferences: Partial<UserPreferences>) => Promise<void>;
  loadUserPreferences: () => Promise<void>;
  resetPreferences: () => Promise<void>;
  
  // Mood Management
  setCurrentMood: (mood: MoodInput | null) => void;
  clearMood: () => void;
  
  // Recommendations
  generateTodaysRecommendation: () => Promise<void>;
  markMovieAsWatched: (movieId: string) => Promise<void>;
  
  // Utility
  setError: (error: string | null) => void;
  clearError: () => void;
}

// Create context
const AppContext = createContext<AppContextType | undefined>(undefined);

// Provider component
interface AppProviderProps {
  children: ReactNode;
}

export const AppProvider: React.FC<AppProviderProps> = ({ children }) => {
  const [state, dispatch] = useReducer(appReducer, initialState);
  
  // Initialize app on mount
  useEffect(() => {
    initializeApp();
  }, []);
  
  // Initialize application
  const initializeApp = async () => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      
      // Load user preferences
      await loadUserPreferences();
      
      // Load movie database (in a real app, this would come from an API)
      const sampleMovies = generateSampleMovieDatabase();
      dispatch({ type: 'SET_MOVIE_DATABASE', payload: sampleMovies });
      
      // Check for today's recommendation
      const dailyService = DailyRecommendationService.getInstance();
      const todaysRec = await dailyService.getTodaysRecommendation();
      dispatch({ type: 'SET_TODAYS_RECOMMENDATION', payload: todaysRec });
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to initialize app' });
      dispatch({ type: 'SET_LOADING', payload: false });
    }
  };
  
  // Load user preferences
  const loadUserPreferences = async () => {
    try {
      const preferences = await UserPreferenceManager.loadPreferences();
      dispatch({ type: 'SET_USER_PREFERENCES', payload: preferences });
    } catch (error) {
      console.error('Error loading preferences:', error);
      dispatch({ type: 'SET_ERROR', payload: 'Failed to load user preferences' });
    }
  };
  
  // Update user preferences
  const updateUserPreferences = async (updates: Partial<UserPreferences>) => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      const updatedPreferences = await UserPreferenceManager.updatePreferences(updates);
      dispatch({ type: 'SET_USER_PREFERENCES', payload: updatedPreferences });
      
      // If notification time changed, reschedule notifications
      if (updates.notificationTime) {
        const dailyService = DailyRecommendationService.getInstance();
        dailyService.scheduleNotification(updatedPreferences);
      }
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to update preferences' });
      dispatch({ type: 'SET_LOADING', payload: false });
    }
  };
  
  // Reset preferences to defaults
  const resetPreferences = async () => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      await UserPreferenceManager.resetToDefaults();
      await loadUserPreferences();
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to reset preferences' });
      dispatch({ type: 'SET_LOADING', payload: false });
    }
  };
  
  // Set current mood
  const setCurrentMood = (mood: MoodInput | null) => {
    dispatch({ type: 'SET_CURRENT_MOOD', payload: mood });
  };
  
  // Clear mood
  const clearMood = () => {
    dispatch({ type: 'SET_CURRENT_MOOD', payload: null });
  };
  
  // Generate today's recommendation
  const generateTodaysRecommendation = async () => {
    try {
      if (!state.userPreferences) {
        dispatch({ type: 'SET_ERROR', payload: 'User preferences not loaded' });
        return;
      }
      
      dispatch({ type: 'SET_LOADING', payload: true });
      
      const dailyService = DailyRecommendationService.getInstance();
      const recommendation = await dailyService.generateDailyRecommendation(
        state.userPreferences,
        state.currentMood || undefined,
        state.movieDatabase
      );
      
      dispatch({ type: 'SET_TODAYS_RECOMMENDATION', payload: recommendation });
      
      // Save today's recommendation
      await dailyService.saveTodaysRecommendation(recommendation);
      
      // Send notification
      await dailyService.sendRecommendationNotification(recommendation);
      
      // Update last recommendation date
      const today = new Date().toISOString().split('T')[0];
      dispatch({ type: 'SET_LAST_RECOMMENDATION_DATE', payload: today });
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to generate recommendation' });
      dispatch({ type: 'SET_LOADING', payload: false });
    }
  };
  
  // Mark movie as watched
  const markMovieAsWatched = async (movieId: string) => {
    try {
      const dailyService = DailyRecommendationService.getInstance();
      await dailyService.markMovieAsWatched(movieId);
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to mark movie as watched' });
    }
  };
  
  // Set error
  const setError = (error: string | null) => {
    dispatch({ type: 'SET_ERROR', payload: error });
  };
  
  // Clear error
  const clearError = () => {
    dispatch({ type: 'SET_ERROR', payload: null });
  };
  
  const contextValue: AppContextType = {
    state,
    updateUserPreferences,
    loadUserPreferences,
    resetPreferences,
    setCurrentMood,
    clearMood,
    generateTodaysRecommendation,
    markMovieAsWatched,
    setError,
    clearError,
  };
  
  return (
    <AppContext.Provider value={contextValue}>
      {children}
    </AppContext.Provider>
  );
};

// Hook to use the context
export const useAppContext = (): AppContextType => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
};

// Generate sample movie database for development
function generateSampleMovieDatabase(): Movie[] {
  return [
    {
      id: '1',
      title: 'The Grand Budapest Hotel',
      genre: [Genre.COMEDY, Genre.DRAMA],
      imdbRating: 8.1,
      releaseYear: 2014,
      runtime: 99,
      synopsis: 'A writer encounters the owner of an aging high-class hotel, who tells him of his early years serving as a lobby boy in the hotel\'s glorious years under an exceptional concierge.',
      trailerUrl: 'https://example.com/trailer1',
      director: 'Wes Anderson',
      actors: ['Ralph Fiennes', 'F. Murray Abraham', 'Mathieu Amalric'],
      moodTags: [MoodTag.UPLIFTING, MoodTag.FUNNY, MoodTag.THOUGHT_PROVOKING],
      posterUrl: 'https://example.com/poster1.jpg'
    },
    {
      id: '2',
      title: 'Inception',
      genre: [Genre.SCIFI, Genre.THRILLER],
      imdbRating: 8.8,
      releaseYear: 2010,
      runtime: 148,
      synopsis: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
      trailerUrl: 'https://example.com/trailer2',
      director: 'Christopher Nolan',
      actors: ['Leonardo DiCaprio', 'Marion Cotillard', 'Tom Hardy'],
      moodTags: [MoodTag.THOUGHT_PROVOKING, MoodTag.INTENSE, MoodTag.EXCITING],
      posterUrl: 'https://example.com/poster2.jpg'
    },
    {
      id: '3',
      title: 'The Princess Bride',
      genre: [Genre.ADVENTURE, Genre.COMEDY, Genre.ROMANCE],
      imdbRating: 8.0,
      releaseYear: 1987,
      runtime: 98,
      synopsis: 'A bedridden boy\'s grandfather reads him the story of a farmboy-turned-pirate who encounters numerous obstacles, enemies and allies in his quest to be reunited with his true love.',
      trailerUrl: 'https://example.com/trailer3',
      director: 'Rob Reiner',
      actors: ['Cary Elwes', 'Robin Wright', 'Mandy Patinkin'],
      moodTags: [MoodTag.UPLIFTING, MoodTag.ROMANTIC, MoodTag.EXCITING],
      posterUrl: 'https://example.com/poster3.jpg'
    },
    {
      id: '4',
      title: 'Parasite',
      genre: [Genre.THRILLER, Genre.DRAMA],
      imdbRating: 8.6,
      releaseYear: 2019,
      runtime: 132,
      synopsis: 'Act of love and betrayal, secrets and lies, a shocking crime and its haunting consequences are explored in this psychological masterpiece.',
      trailerUrl: 'https://example.com/trailer4',
      director: 'Bong Joon Ho',
      actors: ['Song Kang-ho', 'Lee Sun-kyun', 'Cho Yeo-jeong'],
      moodTags: [MoodTag.THOUGHT_PROVOKING, MoodTag.INTENSE],
      posterUrl: 'https://example.com/poster4.jpg'
    },
    {
      id: '5',
      title: 'Spider-Man: Into the Spider-Verse',
      genre: [Genre.ANIMATION, Genre.ACTION, Genre.ADVENTURE],
      imdbRating: 8.4,
      releaseYear: 2018,
      runtime: 117,
      synopsis: 'Teen Miles Morales becomes the Spider-Man of his universe, and must join with five spider-powered individuals from other dimensions to stop a threat for all realities.',
      trailerUrl: 'https://example.com/trailer5',
      director: 'Bob Persichetti',
      actors: ['Shameik Moore', 'Jake Johnson', 'Hailee Steinfeld'],
      moodTags: [MoodTag.EXCITING, MoodTag.UPLIFTING, MoodTag.INSPIRING],
      posterUrl: 'https://example.com/poster5.jpg'
    }
  ];
}
