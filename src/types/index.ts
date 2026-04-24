// Core types for the Uplift Reel app

export interface Movie {
  id: string;
  title: string;
  genre: Genre[];
  imdbRating: number;
  releaseYear: number;
  runtime: number; // in minutes
  synopsis: string;
  trailerUrl: string;
  director: string;
  actors: string[];
  moodTags: MoodTag[];
  posterUrl: string;
}

export enum Genre {
  COMEDY = 'comedy',
  DRAMA = 'drama',
  THRILLER = 'thriller',
  HORROR = 'horror',
  SCIFI = 'sci-fi',
  ROMANCE = 'romance',
  ACTION = 'action',
  DOCUMENTARY = 'documentary',
  ADVENTURE = 'adventure',
  FANTASY = 'fantasy',
  MYSTERY = 'mystery',
  ANIMATION = 'animation'
}

export enum MoodTag {
  EXCITING = 'exciting',
  THOUGHT_PROVOKING = 'thought-provoking',
  SCARY = 'scary',
  ROMANTIC = 'romantic',
  FUNNY = 'funny',
  UPLIFTING = 'uplifting',
  INTENSE = 'intense',
  RELAXING = 'relaxing',
  NOSTALGIC = 'nostalgic',
  INSPIRING = 'inspiring'
}

export enum MoodEmoji {
  HAPPY = '😊',
  SUSPENSE = '😨',
  INTROSPECTIVE = '😔',
  EXCITED = '🤩',
  ROMANTIC = '😍',
  ADVENTUROUS = '🏃‍♂️',
  RELAXED = '😌',
  CURIOUS = '🤔'
}

export interface UserPreferences {
  selectedGenres: Genre[];
  minRating: number;
  maxRating: number;
  preferredActors?: string[];
  preferredDirectors?: string[];
  releaseYearRange?: {
    min: number;
    max: number;
  };
  maxRuntime?: number; // in minutes
  excludedGenres?: Genre[];
  excludedMovies?: string[]; // movie IDs
  notificationTime: string; // 24-hour format: "HH:MM"
}

export interface MoodInput {
  emoji: MoodEmoji;
  intensity: number; // 1-10 scale
  moodSlider: number; // 1-10 scale (1 = fun, 10 = serious)
}

export interface RecommendationContext {
  userPreferences: UserPreferences;
  currentMood?: MoodInput;
  previousRecommendations: string[]; // movie IDs
  watchedMovies: string[]; // movie IDs
}

export interface RecommendationResult {
  movie: Movie;
  matchScore: number; // 0-100
  explanation: string;
  isAlternative: boolean; // true if this is a fallback recommendation
  alternativeReason?: string; // explanation for why it's an alternative
}

export interface RecommendationEngine {
  findBestMatch(context: RecommendationContext, movieDatabase: Movie[]): RecommendationResult;
  calculateMatchScore(movie: Movie, context: RecommendationContext): number;
  handleEdgeCases(context: RecommendationContext, movieDatabase: Movie[]): RecommendationResult | null;
}
