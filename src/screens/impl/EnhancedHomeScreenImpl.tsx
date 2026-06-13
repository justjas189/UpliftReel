import React, { useCallback, useEffect, useState } from 'react';
import {
  Alert,
  Linking,
  RefreshControl,
  ScrollView,
  Share,
  StyleSheet,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAppContext } from '../../context/AppContext';
import { StitchDesignSystem, stitchCommonStyles } from '../../styles/StitchDesignSystem';
import {
  StitchButton,
  StitchCard,
  StitchGenrePill,
  StitchHeader,
  StitchLoading,
  StitchMovieHero,
  StitchRatingStars,
  StitchStreamingBadge,
  StitchTypography,
} from '../../components/StitchUI';
import {
  buildTmdbPosterUrl,
  fetchRecommendations,
  TMDBMovie,
} from '../../services/tmdb';
import { fetchMovieRating } from '../../services/omdb';

interface HomeScreenProps {
  navigation: any;
}

const formatRuntime = (runtime: number): string => {
  const hours = Math.floor(runtime / 60);
  const minutes = runtime % 60;
  return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
};

const titleCase = (value: string): string =>
  value
    .split('-')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');

const TMDB_GENRE_LABELS: Record<number, string> = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Sci-Fi',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

const mapTmdbGenres = (genreIds: number[]): string[] =>
  genreIds
    .map((genreId) => TMDB_GENRE_LABELS[genreId])
    .filter((genreName): genreName is string => Boolean(genreName));

const EnhancedHomeScreenImpl: React.FC<HomeScreenProps> = ({ navigation }) => {
  const {
    state,
    generateTodaysRecommendation,
    markMovieAsWatched,
    updateUserPreferences,
    clearError,
  } = useAppContext();

  const [localRating, setLocalRating] = useState(0);
  const [refreshing, setRefreshing] = useState(false);
  const [isBusy, setIsBusy] = useState(false);
  const [tmdbMovie, setTmdbMovie] = useState<TMDBMovie | null>(null);
  const [tmdbLoading, setTmdbLoading] = useState(false);
  const [tmdbError, setTmdbError] = useState<string | null>(null);
  const [imdbRating, setImdbRating] = useState<number | null>(null);

  const recommendation = state.todaysRecommendation;
  const movie = recommendation?.movie;

  const loadTmdbRecommendation = useCallback(async (showLoader = true) => {
    if (showLoader) {
      setTmdbLoading(true);
    }

    setTmdbError(null);
    setImdbRating(null);

    try {
      const recommendations = await fetchRecommendations();
      const selectedMovie = recommendations[0] ?? null;
      setTmdbMovie(selectedMovie);

      if (selectedMovie) {
        try {
          const releaseYear = selectedMovie.release_date
            ? Number(selectedMovie.release_date.slice(0, 4))
            : undefined;

          const ratingValue = await fetchMovieRating(selectedMovie.title, releaseYear);
          const parsedRating = ratingValue ? Number.parseFloat(ratingValue) : NaN;

          if (!Number.isNaN(parsedRating)) {
            setImdbRating(parsedRating);
          }
        } catch (error) {
          console.error('Failed to bridge TMDB movie to OMDb rating:', error);
        }
      }
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Failed to fetch TMDB recommendations.';
      setTmdbError(message);
    } finally {
      if (showLoader) {
        setTmdbLoading(false);
      }
    }
  }, []);

  useEffect(() => {
    loadTmdbRecommendation().catch(() => {
      // Error state is already handled in local state.
    });
  }, [loadTmdbRecommendation]);

  useEffect(() => {
    if (
      !state.isLoading &&
      !movie &&
      state.userPreferences &&
      state.movieDatabase.length > 0
    ) {
      generateTodaysRecommendation().catch(() => {
        // Error state is already handled by context.
      });
    }
  }, [
    state.isLoading,
    movie,
    state.userPreferences,
    state.movieDatabase.length,
    generateTodaysRecommendation,
  ]);

  const handleRefresh = async () => {
    setRefreshing(true);
    clearError();
    try {
      const refreshTasks: Promise<unknown>[] = [loadTmdbRecommendation(false)];

      if (state.userPreferences && state.movieDatabase.length > 0) {
        refreshTasks.push(generateTodaysRecommendation());
      }

      await Promise.all(refreshTasks);
    } finally {
      setRefreshing(false);
    }
  };

  const handleOpenProfile = () => navigation.navigate('Profile');
  const handleOpenHistory = () => navigation.navigate('History');
  const handleSetMood = () => navigation.navigate('MoodTab');

  const handleWatchTrailer = async () => {
    if (!movie?.trailerUrl) {
      Alert.alert('Trailer unavailable', 'No trailer link is available for this movie yet.');
      return;
    }

    try {
      await Linking.openURL(movie.trailerUrl);
    } catch (_error) {
      Alert.alert('Unable to open trailer', 'Please try again later.');
    }
  };

  const handleViewDetails = () => {
    if (!movie) {
      Alert.alert(
        'Details unavailable',
        'Detailed navigation is currently available for personalized recommendations only.'
      );
      return;
    }

    navigation.navigate('MovieDetails', {
      movie,
      fromScreen: 'Home',
    });
  };

  const handleMarkAsWatched = async () => {
    if (!movie) {
      return;
    }

    setIsBusy(true);
    try {
      await markMovieAsWatched(movie.id);
      Alert.alert('Saved to history', 'Marked as watched.', [
        { text: 'Stay here', style: 'cancel' },
        { text: 'View history', onPress: handleOpenHistory },
      ]);
    } finally {
      setIsBusy(false);
    }
  };

  const handleSkipForNow = async () => {
    if (!movie || !state.userPreferences) {
      return;
    }

    const excludedMovies = state.userPreferences.excludedMovies ?? [];
    if (excludedMovies.includes(movie.id)) {
      Alert.alert('Already skipped', 'This movie is already excluded from recommendations.');
      return;
    }

    setIsBusy(true);
    try {
      await updateUserPreferences({
        excludedMovies: [...excludedMovies, movie.id],
      });
      await generateTodaysRecommendation();
    } finally {
      setIsBusy(false);
    }
  };

  const handleShare = async () => {
    const shareTitle = tmdbMovie?.title ?? movie?.title;
    const shareRating = imdbRating ?? tmdbMovie?.vote_average ?? movie?.imdbRating;
    const shareYear = tmdbMovie?.release_date
      ? Number(tmdbMovie.release_date.slice(0, 4))
      : movie?.releaseYear;

    if (!shareTitle || !shareRating) {
      return;
    }

    try {
      await Share.share({
        title: `Uplift Reel pick: ${shareTitle}`,
        message: `${shareTitle}${shareYear ? ` (${shareYear})` : ''} - ${
          imdbRating !== null ? 'IMDb' : tmdbMovie ? 'TMDB' : 'IMDb'
        } ${shareRating.toFixed(1)}`,
      });
    } catch (_error) {
      // Ignore share dismissal/error.
    }
  };

  if ((state.isLoading || tmdbLoading) && !movie && !tmdbMovie) {
    return (
      <SafeAreaView style={stitchCommonStyles.safeArea}>
        <StitchLoading label="Loading today's movie picks..." />
      </SafeAreaView>
    );
  }

  if (!movie && !tmdbMovie) {
    return (
      <SafeAreaView style={stitchCommonStyles.safeArea}>
        <StitchHeader title="Uplift Reel" onMenuPress={handleOpenHistory} onAvatarPress={handleOpenProfile} />
        <View style={styles.emptyWrap}>
          <StitchCard style={styles.emptyCard}>
            <StitchTypography variant="h2" weight="semibold" align="center">
              Need a lift?
            </StitchTypography>
            <StitchTypography
              variant="body"
              color={StitchDesignSystem.colors.textSecondary}
              align="center"
              style={styles.emptyText}
            >
              Tap below to generate your first personalized recommendation.
            </StitchTypography>
            <StitchButton title="Generate Recommendation" onPress={handleRefresh} loading={refreshing} fullWidth />
            <StitchButton title="Set Mood" variant="outline" onPress={handleSetMood} fullWidth icon="happy-outline" />
          </StitchCard>
        </View>
      </SafeAreaView>
    );
  }

  const tmdbGenres = tmdbMovie ? mapTmdbGenres(tmdbMovie.genre_ids) : [];
  const genres = tmdbMovie
    ? tmdbGenres.length > 0
      ? tmdbGenres
      : ['Popular']
    : movie
    ? movie.genre.map(titleCase)
    : ['Popular'];

  const displayTitle = tmdbMovie?.title ?? movie?.title ?? 'Movie Pick';
  const displaySynopsis = tmdbMovie?.overview || movie?.synopsis || 'No synopsis available.';
  const displayRating = imdbRating ?? tmdbMovie?.vote_average ?? movie?.imdbRating ?? 0;
  const displayStarRating = displayRating / 2;
  const displayRatingSource = imdbRating !== null ? 'IMDb' : tmdbMovie ? 'TMDB' : 'IMDb';
  const displayReleaseYear = tmdbMovie?.release_date
    ? Number(tmdbMovie.release_date.slice(0, 4))
    : movie?.releaseYear;
  const displayPosterUri = tmdbMovie
    ? buildTmdbPosterUrl(tmdbMovie.poster_path)
    : movie?.posterUrl;
  const displaySubtitle = tmdbMovie ? 'Trending now on TMDB' : '';

  const metaSegments: string[] = [];
  if (displayReleaseYear) {
    metaSegments.push(`${displayReleaseYear}`);
  }
  if (!tmdbMovie && movie) {
    metaSegments.push(formatRuntime(movie.runtime));
  }
  metaSegments.push(`${displayRatingSource} ${displayRating.toFixed(1)}`);
  const displayMeta = metaSegments.join(' • ');

  return (
    <SafeAreaView style={stitchCommonStyles.safeArea}>
      <StitchHeader title="Uplift Reel" onMenuPress={handleOpenHistory} onAvatarPress={handleOpenProfile} />

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.contentContainer}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            tintColor={StitchDesignSystem.colors.primary}
            colors={[StitchDesignSystem.colors.primary]}
          />
        }
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.heroWrap}>
          <StitchTypography variant="hero" weight="semibold" color={StitchDesignSystem.colors.primary}>
            Need a lift?
          </StitchTypography>
          <StitchTypography variant="body" color={StitchDesignSystem.colors.textSecondary}>
            Find the perfect movie for your current vibe.
          </StitchTypography>
          <StitchButton title="Set Mood" variant="secondary" onPress={handleSetMood} style={styles.moodButton} icon="happy-outline" />
          {tmdbLoading ? (
            <StitchTypography variant="caption" color={StitchDesignSystem.colors.textSecondary}>
              Syncing live TMDB data...
            </StitchTypography>
          ) : null}
          {tmdbError ? (
            <StitchTypography variant="caption" color={StitchDesignSystem.colors.accent}>
              Live TMDB sync failed. Showing fallback data.
            </StitchTypography>
          ) : null}
        </View>

        <StitchMovieHero
          title={displayTitle}
          subtitle={displaySubtitle}
          genres={genres.slice(0, 2)}
          meta={displayMeta}
          posterUri={displayPosterUri}
          onPress={movie ? handleViewDetails : undefined}
        />

        <View style={styles.detailsGrid}>
          <StitchCard style={styles.synopsisCard}>
            <StitchTypography variant="caption" weight="bold" color={StitchDesignSystem.colors.primary}>
              SYNOPSIS
            </StitchTypography>
            <StitchTypography variant="bodySm" color={StitchDesignSystem.colors.textSecondary} style={styles.synopsisText}>
              {displaySynopsis}
            </StitchTypography>
          </StitchCard>

          <StitchCard style={styles.infoTile}>
            <StitchTypography variant="caption" weight="semibold" color={StitchDesignSystem.colors.textSecondary}>
              RATING
            </StitchTypography>
            <StitchTypography variant="h1" weight="semibold" color={StitchDesignSystem.colors.primary}>
              {displayRating.toFixed(1)}/10
            </StitchTypography>
            <StitchRatingStars rating={displayStarRating} />
          </StitchCard>

          <StitchCard style={styles.infoTile}>
            <StitchTypography variant="caption" weight="semibold" color={StitchDesignSystem.colors.textSecondary}>
              STREAM ON
            </StitchTypography>
            <View style={styles.streamingRow}>
              <StitchStreamingBadge service="Netflix" />
              <StitchStreamingBadge service="Prime Video" />
            </View>
          </StitchCard>
        </View>

        <StitchCard style={styles.actionsCard}>
          <StitchTypography variant="h3" weight="semibold">
            Your quick actions
          </StitchTypography>
          <View style={styles.genreRow}>
            {genres.slice(0, 3).map((genre) => (
              <StitchGenrePill key={genre} label={genre} />
            ))}
          </View>

          <View style={styles.ratingBlock}>
            <StitchTypography variant="bodySm" color={StitchDesignSystem.colors.textSecondary}>
              Rate this recommendation
            </StitchTypography>
            <StitchRatingStars rating={localRating} onRate={setLocalRating} />
          </View>

          <View style={styles.buttonRow}>
            <StitchButton
              title="Watch Trailer"
              variant="outline"
              onPress={handleWatchTrailer}
              style={styles.halfButton}
              icon="play"
              disabled={!movie}
            />
            <StitchButton
              title="View Details"
              onPress={handleViewDetails}
              style={styles.halfButton}
              icon="information-circle-outline"
              disabled={!movie}
            />
          </View>

          <StitchButton
            title={isBusy ? 'Saving...' : 'Watched It'}
            onPress={handleMarkAsWatched}
            loading={isBusy}
            disabled={!movie}
            fullWidth
            icon="checkmark-outline"
          />
          <StitchButton title="Skip for now" variant="ghost" onPress={handleSkipForNow} disabled={!movie} fullWidth />
          <StitchButton title="Share" variant="ghost" onPress={handleShare} fullWidth />
        </StitchCard>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  scrollView: {
    flex: 1,
  },
  contentContainer: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.base,
    paddingBottom: StitchDesignSystem.spacing.xxxl,
  },
  heroWrap: {
    gap: StitchDesignSystem.spacing.sm,
  },
  moodButton: {
    alignSelf: 'flex-start',
    minHeight: 44,
  },
  detailsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  synopsisCard: {
    width: '100%',
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.sm,
  },
  synopsisText: {
    lineHeight: 22,
  },
  infoTile: {
    flex: 1,
    minWidth: 120,
    padding: StitchDesignSystem.spacing.base,
    alignItems: 'center',
    gap: StitchDesignSystem.spacing.sm,
  },
  streamingRow: {
    flexDirection: 'row',
    gap: StitchDesignSystem.spacing.sm,
  },
  actionsCard: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.base,
  },
  genreRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  ratingBlock: {
    gap: StitchDesignSystem.spacing.sm,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: StitchDesignSystem.spacing.sm,
  },
  halfButton: {
    flex: 1,
  },
  emptyWrap: {
    flex: 1,
    justifyContent: 'center',
    padding: StitchDesignSystem.spacing.base,
  },
  emptyCard: {
    padding: StitchDesignSystem.spacing.xxl,
    gap: StitchDesignSystem.spacing.base,
  },
  emptyText: {
    lineHeight: 24,
  },
});

export default EnhancedHomeScreenImpl;
