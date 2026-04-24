import React, { useState } from 'react';
import {
  Alert,
  Linking,
  ScrollView,
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
  StitchMovieHero,
  StitchStreamingBadge,
  StitchTypography,
} from '../../components/StitchUI';

interface MovieDetailsScreenProps {
  navigation: any;
  route: any;
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

const MovieDetailsScreenImpl: React.FC<MovieDetailsScreenProps> = ({ navigation, route }) => {
  const { markMovieAsWatched } = useAppContext();
  const [markingWatched, setMarkingWatched] = useState(false);
  const [isWatched, setIsWatched] = useState(false);

  const movie = route?.params?.movie;

  if (!movie) {
    return (
      <SafeAreaView style={stitchCommonStyles.safeArea}>
        <StitchHeader
          title="Uplift Reel"
          menuIcon="chevron-back"
          onMenuPress={() => navigation.goBack()}
        />
        <View style={styles.errorWrap}>
          <StitchCard style={styles.errorCard}>
            <StitchTypography variant="h2" weight="semibold" align="center">
              Movie not found
            </StitchTypography>
            <StitchButton title="Back" onPress={() => navigation.goBack()} fullWidth />
          </StitchCard>
        </View>
      </SafeAreaView>
    );
  }

  const handleWatchTrailer = async () => {
    if (!movie.trailerUrl) {
      Alert.alert('Trailer unavailable', 'No trailer URL is available for this movie yet.');
      return;
    }

    try {
      await Linking.openURL(movie.trailerUrl);
    } catch (_error) {
      Alert.alert('Unable to open trailer', 'Please try again later.');
    }
  };

  const handleMarkAsWatched = async () => {
    if (isWatched) {
      Alert.alert('Already watched', 'This movie is already in your watched list.');
      return;
    }

    setMarkingWatched(true);
    try {
      await markMovieAsWatched(movie.id);
      setIsWatched(true);
      Alert.alert('Saved', 'Added to your watched history.');
    } finally {
      setMarkingWatched(false);
    }
  };

  const genres = movie.genre.map((genre: string) => titleCase(genre));

  return (
    <SafeAreaView style={stitchCommonStyles.safeArea}>
      <StitchHeader
        title="Uplift Reel"
        menuIcon="chevron-back"
        onMenuPress={() => navigation.goBack()}
        onAvatarPress={() => navigation.navigate('Profile')}
      />

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <StitchMovieHero
          title={movie.title}
          subtitle="Tap below for full context and quick actions."
          genres={genres.slice(0, 2)}
          meta={`${movie.releaseYear} • ${formatRuntime(movie.runtime)} • IMDb ${movie.imdbRating}`}
        />

        <StitchCard style={styles.infoCard}>
          <StitchTypography variant="h2" weight="semibold" color={StitchDesignSystem.colors.primary}>
            Synopsis
          </StitchTypography>
          <StitchTypography variant="body" color={StitchDesignSystem.colors.textSecondary} style={styles.synopsisText}>
            {movie.synopsis}
          </StitchTypography>

          <StitchTypography variant="bodySm" color={StitchDesignSystem.colors.textSecondary}>
            Director: {movie.director}
          </StitchTypography>
          <StitchTypography variant="bodySm" color={StitchDesignSystem.colors.textSecondary}>
            Cast: {(movie.actors || []).join(', ')}
          </StitchTypography>
        </StitchCard>

        <StitchCard style={styles.infoCard}>
          <StitchTypography variant="h3" weight="semibold" color={StitchDesignSystem.colors.primary}>
            Genres
          </StitchTypography>
          <View style={styles.genreRow}>
            {genres.map((genre: string) => (
              <StitchGenrePill key={genre} label={genre} />
            ))}
          </View>
        </StitchCard>

        <StitchCard style={styles.infoCard}>
          <StitchTypography variant="h3" weight="semibold" color={StitchDesignSystem.colors.primary}>
            Stream On
          </StitchTypography>
          <View style={styles.streamingRow}>
            <StitchStreamingBadge service="Netflix" />
            <StitchStreamingBadge service="Prime Video" />
          </View>
        </StitchCard>

        <View style={styles.actionWrap}>
          <StitchButton title="Watch Trailer" variant="secondary" onPress={handleWatchTrailer} fullWidth />
          <StitchButton
            title={isWatched ? 'Watched' : 'Mark as Watched'}
            onPress={handleMarkAsWatched}
            loading={markingWatched}
            fullWidth
          />
        </View>
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
  infoCard: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.sm,
  },
  synopsisText: {
    lineHeight: 24,
  },
  genreRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  streamingRow: {
    flexDirection: 'row',
    gap: StitchDesignSystem.spacing.sm,
  },
  actionWrap: {
    gap: StitchDesignSystem.spacing.sm,
  },
  errorWrap: {
    flex: 1,
    justifyContent: 'center',
    padding: StitchDesignSystem.spacing.base,
  },
  errorCard: {
    padding: StitchDesignSystem.spacing.xxl,
    gap: StitchDesignSystem.spacing.base,
  },
});

export default MovieDetailsScreenImpl;
