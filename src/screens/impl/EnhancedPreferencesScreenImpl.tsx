import React, { useEffect, useMemo, useState } from 'react';
import {
  Alert,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAppContext } from '../../context/AppContext';
import { Genre } from '../../types';
import { UserPreferenceManager } from '../../services/UserPreferenceManager';
import { StitchDesignSystem, stitchCommonStyles } from '../../styles/StitchDesignSystem';
import {
  StitchButton,
  StitchCard,
  StitchHeader,
  StitchTypography,
  StitchRatingStars,
} from '../../components/StitchUI';

interface PreferencesScreenProps {
  navigation: any;
}

const GENRE_OPTIONS: Array<{ id: Genre; label: string }> = [
  { id: Genre.COMEDY, label: 'Comedy' },
  { id: Genre.DRAMA, label: 'Drama' },
  { id: Genre.ACTION, label: 'Action' },
  { id: Genre.THRILLER, label: 'Thriller' },
  { id: Genre.HORROR, label: 'Horror' },
  { id: Genre.ROMANCE, label: 'Romance' },
  { id: Genre.SCIFI, label: 'Sci-Fi' },
  { id: Genre.ADVENTURE, label: 'Adventure' },
  { id: Genre.FANTASY, label: 'Fantasy' },
  { id: Genre.MYSTERY, label: 'Mystery' },
  { id: Genre.ANIMATION, label: 'Animation' },
  { id: Genre.DOCUMENTARY, label: 'Documentary' },
];

const RATING_OPTIONS = [
  { id: 'any', label: 'Any Rating', detail: 'All movies', value: 0 },
  { id: 'decent', label: 'Decent+', detail: '5.0+ IMDb', value: 5 },
  { id: 'good', label: 'Good+', detail: '6.0+ IMDb', value: 6 },
  { id: 'great', label: 'Great+', detail: '7.0+ IMDb', value: 7 },
  { id: 'excellent', label: 'Excellent+', detail: '8.0+ IMDb', value: 8 },
  { id: 'masterpiece', label: 'Masterpiece', detail: '9.0+ IMDb', value: 9 },
] as const;

const LANGUAGES = ['English', 'Korean', 'Japanese', 'Spanish'];

const EnhancedPreferencesScreenImpl: React.FC<PreferencesScreenProps> = ({ navigation }) => {
  const { state, updateUserPreferences, resetPreferences } = useAppContext();
  const [selectedGenres, setSelectedGenres] = useState<Genre[]>([]);
  const [selectedRatingId, setSelectedRatingId] = useState<string>('great');
  const [selectedLanguage, setSelectedLanguage] = useState<string>('English');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!state.userPreferences) {
      return;
    }

    setSelectedGenres(state.userPreferences.selectedGenres);
    const matchingRating = RATING_OPTIONS.find((option) => option.value === state.userPreferences?.minRating);
    setSelectedRatingId(matchingRating?.id ?? 'great');
  }, [state.userPreferences]);

  const selectedRating = useMemo(
    () => RATING_OPTIONS.find((option) => option.id === selectedRatingId) ?? RATING_OPTIONS[3],
    [selectedRatingId],
  );

  const toggleGenre = (genre: Genre) => {
    setSelectedGenres((previous) =>
      previous.includes(genre)
        ? previous.filter((item) => item !== genre)
        : [...previous, genre],
    );
  };

  const handleSave = async () => {
    if (selectedGenres.length === 0) {
      Alert.alert('Select genres', 'Choose at least one genre before saving.');
      return;
    }

    setSaving(true);
    try {
      await updateUserPreferences({
        selectedGenres,
        minRating: selectedRating.value,
      });

      Alert.alert('Saved', 'Preferences updated successfully.', [
        { text: 'Go Home', onPress: () => navigation.navigate('HomeTab') },
      ]);
    } finally {
      setSaving(false);
    }
  };

  const handleReset = async () => {
    Alert.alert('Reset preferences', 'Restore your default profile settings?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Reset',
        style: 'destructive',
        onPress: async () => {
          setSaving(true);
          try {
            await resetPreferences();
            const defaults = UserPreferenceManager.getDefaultPreferences();
            setSelectedGenres(defaults.selectedGenres);
            const rating = RATING_OPTIONS.find((option) => option.value === defaults.minRating);
            setSelectedRatingId(rating?.id ?? 'great');
          } finally {
            setSaving(false);
          }
        },
      },
    ]);
  };

  return (
    <SafeAreaView style={stitchCommonStyles.safeArea}>
      <StitchHeader
        title="Uplift Reel"
        onMenuPress={() => navigation.navigate('History')}
        onAvatarPress={() => navigation.navigate('Profile')}
      />

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.heroTextBlock}>
          <StitchTypography variant="hero" weight="semibold" align="center" color={StitchDesignSystem.colors.primary}>
            Preferences
          </StitchTypography>
          <StitchTypography variant="body" align="center" color={StitchDesignSystem.colors.textSecondary}>
            Tune your recommendation style.
          </StitchTypography>
        </View>

        <StitchCard style={styles.panelCard}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Ionicons name="film-outline" size={24} color={StitchDesignSystem.colors.primary} />
            <StitchTypography variant="h2" weight="semibold" color={StitchDesignSystem.colors.primary}>
              Favorite Genres
            </StitchTypography>
          </View>
          <View style={styles.genreGrid}>
            {GENRE_OPTIONS.map((option) => {
              const selected = selectedGenres.includes(option.id);
              return (
                <TouchableOpacity
                  key={option.id}
                  activeOpacity={0.9}
                  onPress={() => toggleGenre(option.id)}
                  style={[styles.genreOption, selected && styles.genreOptionSelected]}
                >
                  <Ionicons name={selected ? "checkmark" : "add"} size={16} color={selected ? '#FFFFFF' : StitchDesignSystem.colors.primary} />
                  <StitchTypography
                    variant="bodySm"
                    weight={selected ? 'semibold' : 'medium'}
                    color={selected ? '#FFFFFF' : StitchDesignSystem.colors.primary}
                    align="center"
                  >
                    {option.label}
                  </StitchTypography>
                </TouchableOpacity>
              );
            })}
          </View>
        </StitchCard>

        <StitchCard style={styles.panelCard}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Ionicons name="star-outline" size={24} color={StitchDesignSystem.colors.primary} />
            <StitchTypography variant="h2" weight="bold" color={StitchDesignSystem.colors.primary}>
              Minimum IMDb Rating
            </StitchTypography>
          </View>
          <View style={styles.ratingList}>
            {RATING_OPTIONS.map((option) => {
              const selected = option.id === selectedRatingId;
              return (
                <TouchableOpacity
                  key={option.id}
                  activeOpacity={0.9}
                  onPress={() => setSelectedRatingId(option.id)}
                  style={[styles.ratingOption, selected && styles.ratingOptionSelected]}
                >
                  <View>
                    <StitchTypography
                      variant="h3"
                      weight="semibold"
                      color={selected ? StitchDesignSystem.colors.primary : StitchDesignSystem.colors.textPrimary}
                    >
                      {option.label}
                    </StitchTypography>
                    <StitchTypography
                      variant="bodySm"
                      color={selected ? StitchDesignSystem.colors.primary : StitchDesignSystem.colors.textSecondary}
                    >
                      {option.detail}
                    </StitchTypography>
                    <View style={{ marginTop: 4 }}>
                      <StitchRatingStars rating={option.value / 2} />
                    </View>
                  </View>
                  {selected ? (
                    <View style={styles.ratingSelectedBadge}>
                      <Ionicons name="checkmark" size={16} color={StitchDesignSystem.colors.textInverse} />
                    </View>
                  ) : null}
                </TouchableOpacity>
              );
            })}
          </View>
        </StitchCard>

        <StitchCard style={styles.panelCard}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Ionicons name="language-outline" size={24} color={StitchDesignSystem.colors.primary} />
            <StitchTypography variant="h2" weight="bold" color={StitchDesignSystem.colors.primary}>
              Preferred Language
            </StitchTypography>
          </View>
          <View style={styles.languageWrap}>
            {LANGUAGES.map(lang => {
               const selected = selectedLanguage === lang;
               return (
                <TouchableOpacity key={lang} activeOpacity={0.8} onPress={() => setSelectedLanguage(lang)} style={[styles.langPill, selected && styles.langPillSelected]}>
                  <StitchTypography variant="bodySm" weight={selected ? 'semibold' : 'medium'} color={selected ? '#FFFFFF' : StitchDesignSystem.colors.primary}>{lang}</StitchTypography>
                </TouchableOpacity>
               );
            })}
          </View>
        </StitchCard>

        <StitchCard style={styles.darkSummaryCard}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 8 }}>
             <Ionicons name="film" size={26} color="#8AB4F8" />
             <StitchTypography variant="h2" weight="bold" color="#FFFFFF">
               Current Setup
             </StitchTypography>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginVertical: 4 }}>
             <Ionicons name="checkmark-circle" size={20} color="#8AB4F8" />
             <StitchTypography variant="body" color="#D1E4FF" weight="medium">
               {selectedGenres.length} Genres selected
             </StitchTypography>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginVertical: 4 }}>
             <Ionicons name="checkmark-circle" size={20} color="#8AB4F8" />
             <StitchTypography variant="body" color="#D1E4FF" weight="medium">
               Highly rated titles ({selectedRating.value > 0 ? `${selectedRating.value}+` : 'Any'})
             </StitchTypography>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginVertical: 4 }}>
             <Ionicons name="checkmark-circle" size={20} color="#8AB4F8" />
             <StitchTypography variant="body" color="#D1E4FF" weight="medium">
               {selectedLanguage} language
             </StitchTypography>
          </View>

          <View style={styles.dashedButtonContainer}>
            <StitchButton
              title={saving ? 'Saving...' : 'Save Changes'}
              onPress={handleSave}
              loading={saving}
              icon="save"
              style={styles.saveChangesButton}
              textColor="#FFFFFF"
            />
          </View>

          <StitchButton 
            title="Reset Defaults" 
            variant="outline" 
            onPress={handleReset} 
            style={styles.resetDefaultsButton}
            textColor="#FFFFFF"
          />
        </StitchCard>

        <StitchCard style={styles.proTipCard}>
          <View style={styles.proTipIconWrap}>
            <Ionicons name="bulb" size={24} color="#1C1C1C" />
          </View>
          <View style={styles.proTipContent}>
            <StitchTypography variant="h3" weight="semibold" color="#1C1C1C">
              Pro Tip
            </StitchTypography>
            <StitchTypography variant="body" color="#4A5568" style={{ lineHeight: 24, marginTop: 4 }}>
              Mixing distinct genres like <StitchTypography variant="body" weight="bold" color="#1A202C">Comedy</StitchTypography> and <StitchTypography variant="body" weight="bold" color="#1A202C">Sci-Fi</StitchTypography> often yields the most unique and uplifting movie recommendations.
            </StitchTypography>
          </View>
        </StitchCard>
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
    gap: StitchDesignSystem.spacing.sm,
    paddingTop: StitchDesignSystem.spacing.base,
  },
  panelCard: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.base,
  },
  genreGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  genreOption: {
    width: '31.8%',
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.primary,
    borderRadius: StitchDesignSystem.radius.full,
    minHeight: 52,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: StitchDesignSystem.colors.surface,
    flexDirection: 'row',
    gap: 4,
  },
  genreOptionSelected: {
    borderColor: StitchDesignSystem.colors.primary,
    backgroundColor: StitchDesignSystem.colors.primary,
  },
  ratingList: {
    gap: StitchDesignSystem.spacing.sm,
  },
  ratingOption: {
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.borderStrong,
    borderRadius: StitchDesignSystem.radius.sm,
    paddingHorizontal: StitchDesignSystem.spacing.base,
    paddingVertical: StitchDesignSystem.spacing.md,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: StitchDesignSystem.colors.surface,
  },
  ratingOptionSelected: {
    borderColor: StitchDesignSystem.colors.primary,
    backgroundColor: StitchDesignSystem.colors.primarySoft,
  },
  ratingSelectedBadge: {
    minWidth: 34,
    height: 22,
    borderRadius: StitchDesignSystem.radius.full,
    backgroundColor: StitchDesignSystem.colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: StitchDesignSystem.spacing.sm,
  },
  darkSummaryCard: {
    backgroundColor: '#0A2540',
    borderRadius: StitchDesignSystem.radius.xl,
    padding: StitchDesignSystem.spacing.xl,
    ...StitchDesignSystem.shadows.card,
  },
  dashedButtonContainer: {
    marginTop: StitchDesignSystem.spacing.lg,
    marginBottom: StitchDesignSystem.spacing.xs,
    borderWidth: 1.5,
    borderColor: '#396096',
    borderStyle: 'dashed',
    borderRadius: 14,
    padding: 6,
  },
  saveChangesButton: {
    backgroundColor: '#FF6B35',
    borderRadius: StitchDesignSystem.radius.md,
    minHeight: 52,
  },
  resetDefaultsButton: {
    borderColor: '#396096',
    borderWidth: 1,
    borderRadius: StitchDesignSystem.radius.md,
    minHeight: 52,
    backgroundColor: 'transparent',
  },
  languageWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  langPill: {
    borderRadius: StitchDesignSystem.radius.full,
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.primary,
    backgroundColor: StitchDesignSystem.colors.surface,
    paddingHorizontal: StitchDesignSystem.spacing.md,
    paddingVertical: StitchDesignSystem.spacing.sm,
  },
  langPillSelected: {
    backgroundColor: StitchDesignSystem.colors.primary,
  },
  proTipCard: {
    backgroundColor: '#F4F5F8',
    borderRadius: StitchDesignSystem.radius.xl,
    padding: StitchDesignSystem.spacing.xl,
    flexDirection: 'row',
    gap: StitchDesignSystem.spacing.lg,
    borderWidth: 0,
    elevation: 0,
    shadowOpacity: 0,
    marginTop: StitchDesignSystem.spacing.sm,
  },
  proTipIconWrap: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#FFE4D6',
    alignItems: 'center',
    justifyContent: 'center',
  },
  proTipContent: {
    flex: 1,
    justifyContent: 'center',
  },
});

export default EnhancedPreferencesScreenImpl;
