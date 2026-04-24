import React, { useMemo, useState } from 'react';
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
import { Genre, MoodEmoji, MoodInput } from '../../types';
import { StitchDesignSystem, stitchCommonStyles } from '../../styles/StitchDesignSystem';
import {
  StitchButton,
  StitchCard,
  StitchHeader,
  StitchTypography,
} from '../../components/StitchUI';

interface MoodScreenProps {
  navigation: any;
}

interface MoodOption {
  id: string;
  label: string;
  subtitle: string;
  icon: keyof typeof Ionicons.glyphMap;
  emoji: MoodEmoji;
  genres: Genre[];
}

const MOOD_OPTIONS: MoodOption[] = [
  {
    id: 'happy',
    label: 'Happy',
    subtitle: 'Comedy, Feel-Good',
    icon: 'happy-outline',
    emoji: MoodEmoji.HAPPY,
    genres: [Genre.COMEDY, Genre.ROMANCE],
  },
  {
    id: 'relaxed',
    label: 'Relaxed',
    subtitle: 'Drama, Nature',
    icon: 'leaf-outline',
    emoji: MoodEmoji.RELAXED,
    genres: [Genre.DRAMA, Genre.DOCUMENTARY],
  },
  {
    id: 'excited',
    label: 'Excited',
    subtitle: 'Action, Adventure',
    icon: 'flash-outline',
    emoji: MoodEmoji.EXCITED,
    genres: [Genre.ACTION, Genre.ADVENTURE],
  },
  {
    id: 'thoughtful',
    label: 'Thoughtful',
    subtitle: 'Documentary, Sci-Fi',
    icon: 'bulb-outline',
    emoji: MoodEmoji.INTROSPECTIVE,
    genres: [Genre.DOCUMENTARY, Genre.SCIFI],
  },
  {
    id: 'thrilled',
    label: 'Thrilled',
    subtitle: 'Thriller, Horror',
    icon: 'pulse-outline',
    emoji: MoodEmoji.SUSPENSE,
    genres: [Genre.THRILLER, Genre.HORROR],
  },
  {
    id: 'romantic',
    label: 'Romantic',
    subtitle: 'Romance, Drama',
    icon: 'heart-outline',
    emoji: MoodEmoji.ROMANTIC,
    genres: [Genre.ROMANCE, Genre.DRAMA],
  },
  {
    id: 'adventurous',
    label: 'Adventurous',
    subtitle: 'Adventure, Fantasy',
    icon: 'compass-outline',
    emoji: MoodEmoji.ADVENTUROUS,
    genres: [Genre.ADVENTURE, Genre.FANTASY],
  },
  {
    id: 'curious',
    label: 'Curious',
    subtitle: 'Mystery, History',
    icon: 'help-circle-outline',
    emoji: MoodEmoji.CURIOUS,
    genres: [Genre.MYSTERY, Genre.DOCUMENTARY],
  },
];

const ENERGY_OPTIONS = [
  { id: 'low', label: 'Low Key', intensity: 3 },
  { id: 'balanced', label: 'Balanced', intensity: 6 },
  { id: 'high', label: 'High Energy', intensity: 9 },
] as const;

const TIME_OPTIONS = [
  { id: 'quick', label: '< 90 mins', slider: 3 },
  { id: 'standard', label: '90 - 120 mins', slider: 5 },
  { id: 'long', label: '120+ mins', slider: 7 },
  { id: 'series', label: 'A Whole Series', slider: 9 },
] as const;

const EnhancedMoodInputScreenImpl: React.FC<MoodScreenProps> = ({ navigation }) => {
  const { setCurrentMood, generateTodaysRecommendation } = useAppContext();

  const [selectedMoodId, setSelectedMoodId] = useState<string>('happy');
  const [selectedEnergyId, setSelectedEnergyId] = useState<string>('balanced');
  const [selectedTimeId, setSelectedTimeId] = useState<string>('standard');
  const [submitting, setSubmitting] = useState(false);

  const selectedMood = useMemo(
    () => MOOD_OPTIONS.find((option) => option.id === selectedMoodId),
    [selectedMoodId],
  );

  const selectedEnergy = useMemo(
    () => ENERGY_OPTIONS.find((option) => option.id === selectedEnergyId),
    [selectedEnergyId],
  );

  const selectedTime = useMemo(
    () => TIME_OPTIONS.find((option) => option.id === selectedTimeId),
    [selectedTimeId],
  );

  const handleSubmit = async () => {
    if (!selectedMood || !selectedEnergy || !selectedTime) {
      Alert.alert('Incomplete mood', 'Please complete all mood controls.');
      return;
    }

    const moodPayload: MoodInput = {
      emoji: selectedMood.emoji,
      intensity: selectedEnergy.intensity,
      moodSlider: selectedTime.slider,
    };

    setSubmitting(true);
    try {
      setCurrentMood(moodPayload);
      await generateTodaysRecommendation();
      Alert.alert('Mood saved', 'Your next recommendation now matches this mood.', [
        { text: 'Go Home', onPress: () => navigation.navigate('HomeTab') },
      ]);
    } finally {
      setSubmitting(false);
    }
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
            How are you feeling?
          </StitchTypography>
          <StitchTypography
            variant="body"
            align="center"
            color={StitchDesignSystem.colors.textSecondary}
          >
            Select a mood to get personalized movie recommendations.
          </StitchTypography>
        </View>

        <View style={styles.moodGrid}>
          {MOOD_OPTIONS.map((option) => {
            const selected = option.id === selectedMoodId;
            return (
              <TouchableOpacity
                key={option.id}
                activeOpacity={0.9}
                onPress={() => setSelectedMoodId(option.id)}
                style={[styles.moodTile, selected && styles.moodTileSelected]}
              >
                <Ionicons
                  name={option.icon}
                  size={26}
                  color={selected ? StitchDesignSystem.colors.textInverse : StitchDesignSystem.colors.textSecondary}
                />
                <StitchTypography variant="h3" weight="semibold" align="center" color={selected ? StitchDesignSystem.colors.textInverse : StitchDesignSystem.colors.textPrimary}>
                  {option.label}
                </StitchTypography>
                <StitchTypography variant="caption" align="center" color={selected ? StitchDesignSystem.colors.textInverse : StitchDesignSystem.colors.textSecondary}>
                  {option.subtitle}
                </StitchTypography>
                {selected && (
                  <Ionicons
                    name="checkmark-circle"
                    size={20}
                    color={StitchDesignSystem.colors.textInverse}
                    style={{ position: 'absolute', top: 8, right: 8 }}
                  />
                )}
              </TouchableOpacity>
            );
          })}
        </View>

        <StitchCard style={styles.panelCard}>
          <StitchTypography variant="h2" weight="semibold" color={StitchDesignSystem.colors.primary}>
            Energy Level
          </StitchTypography>
          <View style={styles.segmentRow}>
            {ENERGY_OPTIONS.map((option) => {
              const selected = option.id === selectedEnergyId;
              return (
                <TouchableOpacity
                  key={option.id}
                  activeOpacity={0.9}
                  onPress={() => setSelectedEnergyId(option.id)}
                  style={[styles.segmentButton, selected && styles.segmentButtonSelected]}
                >
                  <StitchTypography
                    variant="bodySm"
                    weight={selected ? 'semibold' : 'medium'}
                    align="center"
                    color={selected ? StitchDesignSystem.colors.textInverse : StitchDesignSystem.colors.textPrimary}
                  >
                    {option.label}
                  </StitchTypography>
                </TouchableOpacity>
              );
            })}
          </View>
        </StitchCard>

        <StitchCard style={styles.panelCard}>
          <StitchTypography variant="h2" weight="semibold" color={StitchDesignSystem.colors.primary}>
            Time Available
          </StitchTypography>
          <View style={styles.timeWrap}>
            {TIME_OPTIONS.map((option) => {
              const selected = option.id === selectedTimeId;
              return (
                <TouchableOpacity
                  key={option.id}
                  activeOpacity={0.9}
                  onPress={() => setSelectedTimeId(option.id)}
                  style={[styles.timePill, selected && styles.timePillSelected]}
                >
                  <StitchTypography
                    variant="bodySm"
                    weight={selected ? 'semibold' : 'medium'}
                    color={selected ? StitchDesignSystem.colors.primary : StitchDesignSystem.colors.textPrimary}
                  >
                    {option.label}
                  </StitchTypography>
                </TouchableOpacity>
              );
            })}
          </View>
        </StitchCard>

        <View style={styles.actionWrap}>
          <StitchButton
            title={submitting ? 'Finding movies...' : 'Get Recommendations'}
            onPress={handleSubmit}
            variant="secondary"
            loading={submitting}
            fullWidth
            rightIcon="arrow-forward"
          />
          <StitchButton
            title="Skip for now"
            variant="ghost"
            onPress={() => navigation.navigate('HomeTab')}
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
  heroTextBlock: {
    gap: StitchDesignSystem.spacing.sm,
    paddingTop: StitchDesignSystem.spacing.base,
  },
  moodGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  moodTile: {
    width: '48.5%',
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.borderStrong,
    backgroundColor: StitchDesignSystem.colors.surface,
    borderRadius: StitchDesignSystem.radius.md,
    paddingVertical: StitchDesignSystem.spacing.lg,
    paddingHorizontal: StitchDesignSystem.spacing.base,
    alignItems: 'center',
    gap: StitchDesignSystem.spacing.xs,
    ...StitchDesignSystem.shadows.subtle,
  },
  moodTileSelected: {
    borderWidth: 2,
    borderColor: StitchDesignSystem.colors.primary,
    backgroundColor: StitchDesignSystem.colors.primary,
  },
  panelCard: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.base,
  },
  segmentRow: {
    flexDirection: 'row',
    gap: StitchDesignSystem.spacing.sm,
  },
  segmentButton: {
    flex: 1,
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.borderStrong,
    borderRadius: StitchDesignSystem.radius.sm,
    minHeight: 58,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: StitchDesignSystem.colors.surface,
  },
  segmentButtonSelected: {
    backgroundColor: StitchDesignSystem.colors.primary,
    borderColor: StitchDesignSystem.colors.primary,
  },
  timeWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  timePill: {
    borderRadius: StitchDesignSystem.radius.full,
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.borderStrong,
    backgroundColor: StitchDesignSystem.colors.surface,
    paddingHorizontal: StitchDesignSystem.spacing.base,
    paddingVertical: StitchDesignSystem.spacing.sm,
  },
  timePillSelected: {
    borderColor: StitchDesignSystem.colors.primary,
    backgroundColor: StitchDesignSystem.colors.primarySoft,
  },
  actionWrap: {
    gap: StitchDesignSystem.spacing.sm,
    paddingTop: StitchDesignSystem.spacing.sm,
  },
});

export default EnhancedMoodInputScreenImpl;
