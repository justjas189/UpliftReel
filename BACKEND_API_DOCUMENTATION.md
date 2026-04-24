# Uplift Reel Backend API Documentation

## Overview

The Uplift Reel backend provides a comprehensive movie recommendation system with the following key features:

- **Daily Personalized Recommendations**: AI-powered movie suggestions based on user preferences, mood, and viewing history
- **Hybrid Recommendation Engine**: Combines content-based filtering, collaborative filtering, and machine learning
- **Mood-Based Filtering**: Emoji-driven mood detection for contextual recommendations
- **Push Notifications**: Smart notification system for daily movie delivery
- **User Analytics**: Detailed insights into viewing patterns and preferences
- **Privacy-First Design**: GDPR compliant with user data protection

## Architecture

### Service Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Frontend (React Native)                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                BackendAPIService                            │
│  (Main API orchestrator and endpoint handler)              │
└─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┘
      │     │     │     │     │     │     │     │     │
      ▼     ▼     ▼     ▼     ▼     ▼     ▼     ▼     ▼
┌─────────┐ │ ┌───▼──┐ │ ┌───▼──┐ │ ┌───▼──┐ │ ┌───▼──┐
│Firebase │ │ │Hybrid│ │ │  ML  │ │ │Notif │ │ │Daily │
│Service  │ │ │Recom │ │ │Recom │ │ │Serv  │ │ │Recom │
└─────────┘ │ │mend  │ │ │mend  │ │ │ice   │ │ │mend  │
            │ └──────┘ │ └──────┘ │ └──────┘ │ └──────┘
            ▼          ▼          ▼          ▼
      ┌───────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
      │External   │ │User      │ │Mood      │ │Simple    │
      │API        │ │Preference│ │Detection │ │Recom     │
      │Service    │ │Manager   │ │Service   │ │Engine    │
      └───────────┘ └──────────┘ └──────────┘ └──────────┘
```

### Data Flow

1. **User Request** → BackendAPIService
2. **Service Orchestration** → Multiple specialized services
3. **Data Processing** → Firebase/External APIs
4. **ML Processing** → Hybrid recommendation algorithms
5. **Response** → Structured API response to frontend

## API Endpoints

### 1. Get Daily Recommendation

**Endpoint**: `GET /api/recommendation/daily`

**Request**:
```json
{
  "userId": "user123",
  "mood": {
    "emoji": "😊",
    "intensity": 8
  },
  "forceNew": false,
  "algorithm": "hybrid"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "movie": {
      "id": "movie456",
      "title": "The Grand Budapest Hotel",
      "genres": ["Comedy", "Drama"],
      "imdbRating": 8.1,
      "releaseYear": 2014,
      "runtime": 99,
      "director": "Wes Anderson",
      "cast": ["Ralph Fiennes", "F. Murray Abraham"],
      "synopsis": "A legendary concierge at a famous European hotel...",
      "posterUrl": "https://...",
      "moodTags": ["uplifting", "quirky", "visually stunning"]
    },
    "score": 92.5,
    "confidence": 87,
    "explanation": "🎯 Perfect match! This recommendation matches your preferred genres and ratings, fits your viewing patterns perfectly, aligns with your current mood.",
    "algorithm": "hybrid",
    "isAlternative": false
  },
  "timestamp": "2024-01-15T19:30:00Z",
  "requestId": "req_1705347000_abc123"
}
```

### 2. Search Movies

**Endpoint**: `GET /api/movies/search`

**Parameters**:
- `query` (string): Text search query
- `genres` (array): Genre filters
- `minRating` (number): Minimum IMDb rating
- `maxRating` (number): Maximum IMDb rating
- `releaseYear` (number): Release year filter
- `page` (number): Page number for pagination
- `limit` (number): Results per page

**Response**:
```json
{
  "success": true,
  "data": {
    "movies": [...],
    "totalCount": 1250,
    "page": 1,
    "totalPages": 63
  },
  "timestamp": "2024-01-15T19:30:00Z",
  "requestId": "req_1705347000_def456"
}
```

### 3. Get Movie Details

**Endpoint**: `GET /api/movies/{movieId}`

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "movie456",
    "title": "Inception",
    "genres": ["Action", "Sci-Fi", "Thriller"],
    "imdbRating": 8.8,
    "releaseYear": 2010,
    "runtime": 148,
    "director": "Christopher Nolan",
    "cast": ["Leonardo DiCaprio", "Marion Cotillard"],
    "synopsis": "A thief who steals corporate secrets...",
    "streamingInfo": {
      "netflix": true,
      "amazonPrime": false,
      "hulu": true
    },
    "reviews": [
      {
        "source": "critics",
        "score": 87,
        "summary": "A mind-bending masterpiece..."
      }
    ]
  },
  "timestamp": "2024-01-15T19:30:00Z",
  "requestId": "req_1705347000_ghi789"
}
```

### 4. Update User Preferences

**Endpoint**: `PUT /api/user/{userId}/preferences`

**Request**:
```json
{
  "userId": "user123",
  "preferences": {
    "genres": ["Action", "Sci-Fi", "Thriller"],
    "ratingRange": { "min": 7.0, "max": 10.0 },
    "preferredActors": ["Leonardo DiCaprio", "Tom Hardy"],
    "preferredDirectors": ["Christopher Nolan", "Denis Villeneuve"],
    "excludedGenres": ["Horror"],
    "streamingServices": ["netflix", "hulu"]
  }
}
```

### 5. Rate Movie

**Endpoint**: `POST /api/movies/{movieId}/rate`

**Request**:
```json
{
  "userId": "user123",
  "movieId": "movie456",
  "rating": 8,
  "review": "Amazing cinematography and storytelling!",
  "mood": "excited"
}
```

### 6. Update Notification Settings

**Endpoint**: `PUT /api/user/{userId}/notifications`

**Request**:
```json
{
  "userId": "user123",
  "enabled": true,
  "time": "19:00",
  "frequency": "daily",
  "weekdays": [1, 2, 3, 4, 5]
}
```

### 7. Get User Analytics

**Endpoint**: `GET /api/user/{userId}/analytics`

**Response**:
```json
{
  "success": true,
  "data": {
    "watchingPatterns": {
      "totalMoviesWatched": 127,
      "averageRating": 7.8,
      "favoriteGenres": ["Sci-Fi", "Thriller", "Drama"],
      "watchingFrequency": "Regular watcher"
    },
    "preferences": {
      "genrePreferences": ["Sci-Fi", "Action", "Thriller"],
      "ratingRange": { "min": 7.0, "max": 10.0 }
    },
    "engagement": {
      "notificationEngagement": {
        "deliveryRate": 98.5,
        "openRate": 76.3,
        "clickRate": 42.1
      },
      "recommendationAcceptanceRate": 73.2
    },
    "insights": [
      "🎯 Our recommendations are hitting the mark - 85%+ match rate!",
      "🎬 You've discovered 15 new favorite actors this year"
    ]
  }
}
```

## Recommendation Algorithms

### 1. Hybrid Recommendation System

The system combines multiple approaches for optimal recommendations:

- **Content-Based Filtering (25%)**: Matches based on movie features and user preferences
- **Collaborative Filtering (25%)**: Uses similar user preferences
- **Machine Learning Models (30%)**: Neural networks and deep learning
- **Mood-Based Filtering (15%)**: Contextual mood matching
- **Popularity Scoring (5%)**: Trending and highly-rated movies

### 2. Scoring System (100-point scale)

```
Total Score = Σ(Algorithm Weight × Algorithm Score)

Content-Based:
- Genre Match: 40 points
- Rating Range: 20 points  
- Actor/Director Preference: 15 points
- Historical Preferences: 15 points
- Runtime Match: 10 points

Mood-Based:
- Emoji-Tag Matching: 60 points
- Intensity Weighting: 25 points
- Seriousness Level: 15 points

Collaborative:
- Similar User Ratings: 70 points
- User Similarity Score: 30 points

ML Model:
- Neural Collaborative Filtering: 40%
- Content-Based Neural Network: 40%
- Matrix Factorization: 20%
```

### 3. Edge Case Handling

When strict criteria yield no results, the system employs a three-tier fallback strategy:

1. **Relax Rating Range**: Expand by ±0.5 points
2. **Broaden Genre Selection**: Include related genres
3. **Emergency Fallback**: Universally acclaimed classics

## Machine Learning Features

### User Feature Extraction
- Genre preference vectors
- Rating patterns and distribution
- Temporal viewing patterns
- Actor/director affinity scores
- Mood correlation patterns

### Movie Feature Extraction
- Genre one-hot encoding
- Rating and popularity metrics
- Cast and crew embeddings
- Release year and runtime normalization
- Mood tag embeddings

### Context Features
- Time of day and day of week
- Seasonal patterns
- Current mood intensity
- Previous session behavior

## Notification System

### Smart Scheduling
- User timezone awareness
- Optimal delivery time calculation
- Frequency preference handling
- Engagement-based optimization

### Notification Types
- **Daily Recommendations**: Personalized movie suggestions
- **Reminders**: Watch later list items
- **Updates**: New releases in preferred genres
- **Insights**: Weekly/monthly analytics summaries

### Platform Support
- iOS (APNS)
- Android (FCM)
- Web (Web Push)

## Privacy and Security

### GDPR Compliance
- User data anonymization
- Right to be forgotten implementation
- Data export functionality
- Consent management

### Data Protection
- End-to-end encryption for sensitive data
- Anonymized analytics
- Minimal data collection principle
- Secure token management

### Rate Limiting
- API endpoint protection
- User-based throttling
- DDoS protection
- Circuit breaker patterns

## Performance Optimization

### Caching Strategy
- **L1 Cache**: In-memory application cache
- **L2 Cache**: Redis distributed cache
- **L3 Cache**: CDN for static content

### Database Optimization
- Indexed queries for fast lookups
- Read replicas for scaling
- Data partitioning by user
- Batch processing for ML training

### Scalability
- Microservices architecture
- Horizontal scaling capability
- Load balancing
- Queue-based background processing

## Error Handling

### Standard Error Responses
```json
{
  "success": false,
  "error": "User not found",
  "timestamp": "2024-01-15T19:30:00Z",
  "requestId": "req_1705347000_error123"
}
```

### Error Codes
- `USER_NOT_FOUND`: User profile doesn't exist
- `MOVIE_NOT_FOUND`: Movie data unavailable
- `INVALID_PREFERENCES`: Malformed preference data
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `SERVICE_UNAVAILABLE`: External API failure
- `INSUFFICIENT_DATA`: Not enough data for recommendation

## Development and Testing

### Environment Setup
1. Install dependencies: `npm install`
2. Set up Firebase configuration
3. Configure external API keys
4. Start development server: `npm run dev`

### Testing Strategy
- Unit tests for all services
- Integration tests for API endpoints
- Load testing for scalability
- A/B testing for algorithm performance

### Monitoring and Analytics
- Performance metrics tracking
- Error rate monitoring
- User engagement analytics
- Recommendation effectiveness metrics

## Deployment

### Infrastructure
- **Container Orchestration**: Kubernetes
- **Database**: Firebase Firestore + Redis
- **Message Queue**: Firebase Cloud Messaging
- **Monitoring**: Application performance monitoring
- **CI/CD**: Automated testing and deployment pipelines

### Environment Configuration
- Development: Local testing environment
- Staging: Pre-production testing
- Production: Live user-facing system

This comprehensive backend system provides a robust, scalable, and intelligent movie recommendation platform that adapts to user preferences and delivers personalized experiences through advanced machine learning and user-centric design.
