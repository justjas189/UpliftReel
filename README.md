# Uplift Reel - Daily Movie Recommendation App

## Overview

Uplift Reel is a React Native mobile application that delivers personalized daily movie recommendations based on user preferences, mood, and viewing history. The app combines genre preferences, IMDb ratings, and mood-based filtering to provide one perfect movie suggestion per day.

## Features

### 🎬 Daily Recommendations
- One personalized movie recommendation per day
- Push notifications at user-configurable times
- Spoiler-free synopsis with trailer links
- Detailed explanation of why the movie matches your preferences

### 🎭 Mood-Based Filtering
- Emoji-based mood input (😊, 😨, 😔, 🤩, 😍, 🏃‍♂️, 😌, 🤔)
- Intensity slider for mood strength
- Fun-to-serious scale for content preference
- Dynamic recommendation adaptation based on current feelings

### ⚙️ Preference Customization
- Multiple genre selection (comedy, drama, thriller, horror, sci-fi, romance, action, documentary)
- IMDb rating range (1-10 stars)
- Preferred actors and directors
- Release year filtering
- Maximum runtime preferences
- Exclusion lists for genres and specific movies

### 🔄 Smart Edge Case Handling
- Relaxed rating constraints for better matches
- Genre expansion to related categories
- Alternative recommendations with explanations
- Fallback system for highly restrictive preferences

## Technical Architecture

### Core Components

1. **RecommendationEngine** - Core algorithmic logic for movie selection
2. **DailyRecommendationService** - Handles daily delivery and notifications
3. **MoodDetectionService** - Processes mood inputs and converts to filters
4. **UserPreferenceManager** - Manages user settings and data persistence

### Technology Stack

- **Frontend**: React Native with TypeScript
- **State Management**: React Context API with useReducer
- **Storage**: AsyncStorage for local data persistence
- **Notifications**: React Native Push Notifications
- **Navigation**: React Navigation 6

## Installation & Setup

### Prerequisites
- Node.js 16+
- React Native CLI
- Android Studio / Xcode for device testing

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd UpliftReel-Mobile
   ```

2. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

3. **iOS Setup** (if targeting iOS)
   ```bash
   cd ios && pod install && cd ..
   ```

4. **Run the application**
   ```bash
   # Android
   npm run android
   
   # iOS
   npm run ios
   
   # Start Metro bundler
   npm start
   ```

## Project Structure

```
src/
├── components/          # Reusable UI components
├── context/            # React Context for state management
├── screens/            # Main app screens
├── services/           # Core business logic and API services
├── types/              # TypeScript type definitions
└── utils/              # Utility functions and helpers
```

## Core Algorithm

### Recommendation Flow

1. **Input Processing**: Validate user preferences and mood inputs
2. **Hard Filtering**: Apply genre, rating, and exclusion constraints
3. **Mood Filtering**: Filter based on emotional state and intensity
4. **Score Calculation**: Rate movies on multiple compatibility factors
5. **Selection**: Choose highest-scoring unviewed movie
6. **Edge Cases**: Handle restrictive criteria with alternative suggestions

### Scoring System (100 points total)

- **Genre Match**: 40 points - Perfect/partial genre alignment
- **Rating Score**: 20 points - Preference for higher ratings within range
- **Personal Preferences**: 15 points - Favorite actors/directors bonus
- **Mood Alignment**: 15 points - Emotional state compatibility
- **Runtime Preference**: 10 points - Length preference matching

### Edge Case Strategies

1. **Rating Relaxation**: Slightly expand rating bounds for better matches
2. **Genre Expansion**: Include related genres (action → adventure, thriller)
3. **Fallback System**: High-rated movies from preferred genres as last resort

## Usage Examples

### Perfect Match Scenario
```
Input: Comedy + Drama, 7-9 rating, 😊 Happy mood
Result: "🎯 Perfect match! This comedy/drama film matches your genre 
         preferences with its excellent 8.2/10 IMDb rating and fits 
         your current upbeat mood!"
```

### Edge Case Handling
```
Input: Documentary only, 9-10 rating, specific actor preference
Result: "This is rated 8.7, just below your 9.0 minimum, but it's 
         highly regarded in documentary and features your preferred style!"
```

## Configuration

### User Preferences
All preferences are stored locally using AsyncStorage and include:

- Selected genres (multiple choice)
- Rating range (min/max sliders)
- Preferred actors/directors (searchable lists)
- Release year range (date pickers)
- Maximum runtime (slider)
- Excluded content (blacklists)
- Notification timing (time picker)

### Mood Settings
Mood inputs are processed in real-time:

- Emoji selection for emotional state
- Intensity slider (1-10)
- Seriousness scale (fun ←→ serious)
- Automatic time-of-day suggestions

## API Integration

The app is designed to integrate with movie databases like:

- **TMDB (The Movie Database)** - Primary movie data source
- **OMDB API** - Additional ratings and details
- **YouTube API** - Trailer links and previews

*Note: Current version includes sample data for development*

## Development

### Available Scripts

- `npm start` - Start Metro bundler
- `npm run android` - Run on Android device/emulator
- `npm run ios` - Run on iOS device/simulator
- `npm test` - Run test suite
- `npm run lint` - Check code style

### Testing Strategy

- **Unit Tests**: Algorithm logic, scoring functions, edge cases
- **Integration Tests**: Service interactions, data persistence
- **E2E Tests**: Complete recommendation flow, notification delivery

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## Roadmap

### Upcoming Features
- [ ] Social sharing and friend recommendations
- [ ] Watchlist integration with streaming services
- [ ] Advanced mood detection using device sensors
- [ ] Machine learning-based preference evolution
- [ ] Multiple daily recommendations for different moods
- [ ] Group recommendation system for movie nights

### Technical Improvements
- [ ] Offline-first architecture with sync
- [ ] Advanced caching strategies
- [ ] Performance optimization for large datasets
- [ ] Accessibility improvements
- [ ] Internationalization (i18n)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or feature requests:
- Open an issue on GitHub
- Contact: support@upliftreel.com
- Documentation: [docs.upliftreel.com](https://docs.upliftreel.com)

---

Made with ❤️ for movie lovers who want the perfect film for their mood.
