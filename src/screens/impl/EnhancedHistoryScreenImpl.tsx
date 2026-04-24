import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  RefreshControl,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAppContext } from '../../context/AppContext';
import { Movie } from '../../types';
import { StitchDesignSystem, stitchCommonStyles } from '../../styles/StitchDesignSystem';
import {
  StitchCard,
  StitchGenrePill,
  StitchHeader,
  StitchLoading,
  StitchRatingStars,
  StitchTypography,
} from '../../components/StitchUI';

interface HistoryScreenProps {
  navigation: any;
}

interface HistoryEntry {
  id: string;
  movie: Movie;
  watchedDate: string;
  isRecommendation: boolean;
  isWatched: boolean;
  matchScore?: number;
}

const titleCase = (value: string): string =>
  value
    .split('-')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');

const EnhancedHistoryScreenImpl: React.FC<HistoryScreenProps> = ({ navigation }) => {
  const { state } = useAppContext();

  const [history, setHistory] = useState<HistoryEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [selectedTab, setSelectedTab] = useState<'all' | 'recommendations' | 'watched'>('all');
  const [sortBy, setSortBy] = useState<'date' | 'title' | 'score'>('date');

  const loadHistory = useCallback(async () => {
    setLoading(true);
    try {
      const [recommendationRaw, watchedRaw] = await Promise.all([
        AsyncStorage.getItem('recommendation_history'),
        AsyncStorage.getItem('watched_movies'),
      ]);

      const recommendationIds: string[] = recommendationRaw ? JSON.parse(recommendationRaw) : [];
      const watchedIds: string[] = watchedRaw ? JSON.parse(watchedRaw) : [];
      const uniqueIds = Array.from(new Set([...recommendationIds, ...watchedIds]));

      const movieMap = new Map(state.movieDatabase.map((movie) => [movie.id, movie]));
      const entries: HistoryEntry[] = [];

      for (const id of uniqueIds) {
        const movie = movieMap.get(id);
        if (!movie) {
          continue;
        }

        const recommendationMetaRaw = await AsyncStorage.getItem(`recommendation_${id}`);
        const recommendationMeta = recommendationMetaRaw ? JSON.parse(recommendationMetaRaw) : {};

        entries.push({
          id,
          movie,
          watchedDate: recommendationMeta.date || new Date().toISOString(),
          isRecommendation: recommendationIds.includes(id),
          isWatched: watchedIds.includes(id),
          matchScore: recommendationMeta.matchScore,
        });
      }

      if (state.todaysRecommendation && !uniqueIds.includes(state.todaysRecommendation.movie.id)) {
        entries.unshift({
          id: state.todaysRecommendation.movie.id,
          movie: state.todaysRecommendation.movie,
          watchedDate: new Date().toISOString(),
          isRecommendation: true,
          isWatched: false,
          matchScore: state.todaysRecommendation.matchScore,
        });
      }

      entries.sort((a, b) => new Date(b.watchedDate).getTime() - new Date(a.watchedDate).getTime());
      setHistory(entries);
    } finally {
      setLoading(false);
    }
  }, [state.movieDatabase, state.todaysRecommendation]);

  useEffect(() => {
    loadHistory().catch(() => {
      setLoading(false);
    });
  }, [loadHistory]);

  const handleRefresh = async () => {
    setRefreshing(true);
    try {
      await loadHistory();
    } finally {
      setRefreshing(false);
    }
  };

  const filteredHistory = useMemo(() => {
    const scoped =
      selectedTab === 'recommendations'
        ? history.filter((item) => item.isRecommendation)
        : selectedTab === 'watched'
        ? history.filter((item) => item.isWatched)
        : history;

    return [...scoped].sort((a, b) => {
      if (sortBy === 'title') {
        return a.movie.title.localeCompare(b.movie.title);
      }

      if (sortBy === 'score') {
        return (b.matchScore ?? 0) - (a.matchScore ?? 0);
      }

      return new Date(b.watchedDate).getTime() - new Date(a.watchedDate).getTime();
    });
  }, [history, selectedTab, sortBy]);

  const averageScore =
    history.length > 0
      ? Math.round(
          history.reduce((accumulator, item) => accumulator + (item.matchScore ?? 0), 0) /
            history.length,
        )
      : 0;

  if (loading) {
    return (
      <SafeAreaView style={stitchCommonStyles.safeArea}>
        <StitchLoading label="Loading your movie journey..." />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={stitchCommonStyles.safeArea}>
      <StitchHeader
        title="Uplift Reel"
        onMenuPress={() => navigation.navigate('HomeTab')}
        onAvatarPress={() => navigation.navigate('Profile')}
      />

      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            tintColor={StitchDesignSystem.colors.primary}
            colors={[StitchDesignSystem.colors.primary]}
          />
        }
      >
        <View style={styles.heroTextBlock}>
          <StitchTypography variant="hero" weight="semibold" color={StitchDesignSystem.colors.primary}>
            History
          </StitchTypography>
          <StitchTypography variant="body" color={StitchDesignSystem.colors.textSecondary}>
            {history.length} titles tracked, average match score {averageScore}
          </StitchTypography>
        </View>

        <StitchCard style={styles.filterCard}>
          <View style={styles.filterRow}>
            <TouchableOpacity
              style={[styles.filterButton, selectedTab === 'all' && styles.filterButtonSelected]}
              onPress={() => setSelectedTab('all')}
            >
              <StitchTypography
                variant="bodySm"
                weight="semibold"
                color={selectedTab === 'all' ? StitchDesignSystem.colors.textInverse : StitchDesignSystem.colors.textPrimary}
              >
                All
              </StitchTypography>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.filterButton, selectedTab === 'recommendations' && styles.filterButtonSelected]}
              onPress={() => setSelectedTab('recommendations')}
            >
              <StitchTypography
                variant="bodySm"
                weight="semibold"
                color={selectedTab === 'recommendations' ? StitchDesignSystem.colors.textInverse : StitchDesignSystem.colors.textPrimary}
              >
                Picks
              </StitchTypography>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.filterButton, selectedTab === 'watched' && styles.filterButtonSelected]}
              onPress={() => setSelectedTab('watched')}
            >
              <StitchTypography
                variant="bodySm"
                weight="semibold"
                color={selectedTab === 'watched' ? StitchDesignSystem.colors.textInverse : StitchDesignSystem.colors.textPrimary}
              >
                Watched
              </StitchTypography>
            </TouchableOpacity>
          </View>

          <View style={styles.sortRow}>
            <TouchableOpacity onPress={() => setSortBy('date')}>
              <StitchTypography variant="caption" color={sortBy === 'date' ? StitchDesignSystem.colors.primary : StitchDesignSystem.colors.textSecondary}>
                Sort: Date
              </StitchTypography>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => setSortBy('title')}>
              <StitchTypography variant="caption" color={sortBy === 'title' ? StitchDesignSystem.colors.primary : StitchDesignSystem.colors.textSecondary}>
                Title
              </StitchTypography>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => setSortBy('score')}>
              <StitchTypography variant="caption" color={sortBy === 'score' ? StitchDesignSystem.colors.primary : StitchDesignSystem.colors.textSecondary}>
                Score
              </StitchTypography>
            </TouchableOpacity>
          </View>
        </StitchCard>

        {filteredHistory.length === 0 ? (
          <StitchCard style={styles.emptyCard}>
            <StitchTypography variant="h3" weight="semibold" align="center">
              Nothing here yet
            </StitchTypography>
            <StitchTypography variant="body" color={StitchDesignSystem.colors.textSecondary} align="center">
              Watch a movie or generate a recommendation to start your timeline.
            </StitchTypography>
          </StitchCard>
        ) : (
          filteredHistory.map((entry) => {
            const starRating = Math.max(1, Math.round((entry.matchScore ?? 70) / 20));
            return (
              <StitchCard
                key={`${entry.id}-${entry.watchedDate}`}
                style={styles.historyCard}
                onPress={() =>
                  navigation.navigate('MovieDetails', {
                    movie: entry.movie,
                    fromScreen: 'History',
                  })
                }
              >
                <View style={styles.historyTopRow}>
                  <StitchTypography variant="h2" weight="semibold" style={styles.titleText}>
                    {entry.movie.title}
                  </StitchTypography>
                  {entry.isRecommendation ? (
                    <View style={styles.badge}>
                      <StitchTypography variant="caption" weight="bold" color={StitchDesignSystem.colors.textInverse}>
                        DAILY PICK
                      </StitchTypography>
                    </View>
                  ) : null}
                </View>

                <StitchTypography variant="bodySm" color={StitchDesignSystem.colors.textSecondary}>
                  {entry.movie.releaseYear} • {entry.movie.runtime} mins • IMDb {entry.movie.imdbRating}
                </StitchTypography>

                <View style={styles.genreRow}>
                  {entry.movie.genre.slice(0, 3).map((genre) => (
                    <StitchGenrePill key={`${entry.id}-${genre}`} label={titleCase(genre)} />
                  ))}
                </View>

                <View style={styles.footerRow}>
                  <StitchRatingStars rating={starRating} />
                  <StitchTypography variant="caption" color={StitchDesignSystem.colors.textSecondary}>
                    {new Date(entry.watchedDate).toLocaleDateString()}
                  </StitchTypography>
                </View>
              </StitchCard>
            );
          })
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  content: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.base,
    paddingBottom: StitchDesignSystem.spacing.xxxl,
  },
  heroTextBlock: {
    gap: StitchDesignSystem.spacing.xs,
    paddingTop: StitchDesignSystem.spacing.base,
  },
  filterCard: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.sm,
  },
  filterRow: {
    flexDirection: 'row',
    gap: StitchDesignSystem.spacing.sm,
  },
  filterButton: {
    flex: 1,
    minHeight: 36,
    borderRadius: StitchDesignSystem.radius.full,
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.borderStrong,
    alignItems: 'center',
    justifyContent: 'center',
  },
  filterButtonSelected: {
    backgroundColor: StitchDesignSystem.colors.primary,
    borderColor: StitchDesignSystem.colors.primary,
  },
  sortRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  emptyCard: {
    padding: StitchDesignSystem.spacing.xxl,
    gap: StitchDesignSystem.spacing.sm,
  },
  historyCard: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.sm,
  },
  historyTopRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    gap: StitchDesignSystem.spacing.sm,
  },
  titleText: {
    flex: 1,
  },
  badge: {
    borderRadius: StitchDesignSystem.radius.full,
    backgroundColor: StitchDesignSystem.colors.primary,
    paddingHorizontal: StitchDesignSystem.spacing.sm,
    paddingVertical: StitchDesignSystem.spacing.xxs,
  },
  genreRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  footerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
});

export default EnhancedHistoryScreenImpl;
