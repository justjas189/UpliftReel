import React from 'react';
import {
  ActivityIndicator,
  GestureResponderEvent,
  StyleSheet,
  Text,
  TextStyle,
  TouchableOpacity,
  View,
  ViewStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { StitchDesignSystem } from '../styles/StitchDesignSystem';

type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost';

type TypographyVariant =
  | 'hero'
  | 'h1'
  | 'h2'
  | 'h3'
  | 'body'
  | 'bodySm'
  | 'caption';

interface StitchButtonProps {
  title: string;
  onPress: (event: GestureResponderEvent) => void;
  variant?: ButtonVariant;
  disabled?: boolean;
  loading?: boolean;
  fullWidth?: boolean;
  style?: ViewStyle;
  icon?: keyof typeof Ionicons.glyphMap;
  rightIcon?: keyof typeof Ionicons.glyphMap;
  textColor?: string;
}

export const StitchButton: React.FC<StitchButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  disabled,
  loading,
  fullWidth,
  style,
  icon,
  rightIcon,
  textColor,
}) => {
  const variantStyle =
    variant === 'primary'
      ? styles.buttonPrimary
      : variant === 'secondary'
      ? styles.buttonSecondary
      : variant === 'outline'
      ? styles.buttonOutline
      : styles.buttonGhost;

  const textStyle =
    variant === 'outline' || variant === 'ghost'
      ? styles.buttonTextDark
      : styles.buttonTextLight;

  return (
    <TouchableOpacity
      activeOpacity={0.86}
      onPress={onPress}
      disabled={disabled || loading}
      style={[
        styles.buttonBase,
        variantStyle,
        fullWidth && styles.fullWidth,
        (disabled || loading) && styles.buttonDisabled,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator
          color={textColor ? textColor : (variant === 'outline' || variant === 'ghost' ? StitchDesignSystem.colors.primary : StitchDesignSystem.colors.textInverse)}
        />
      ) : (
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
          {icon && <Ionicons name={icon} size={20} color={textColor ? textColor : (StyleSheet.flatten(textStyle).color as string)} />}
          <Text style={[styles.buttonText, textStyle, textColor ? { color: textColor } : null]}>{title}</Text>
          {rightIcon && <Ionicons name={rightIcon} size={20} color={textColor ? textColor : (StyleSheet.flatten(textStyle).color as string)} />}
        </View>
      )}
    </TouchableOpacity>
  );
};

interface StitchCardProps {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: () => void;
}

export const StitchCard: React.FC<StitchCardProps> = ({ children, style, onPress }) => {
  if (onPress) {
    return (
      <TouchableOpacity activeOpacity={0.92} onPress={onPress} style={[styles.card, style]}>
        {children}
      </TouchableOpacity>
    );
  }

  return <View style={[styles.card, style]}>{children}</View>;
};

interface StitchTypographyProps {
  children: React.ReactNode;
  variant?: TypographyVariant;
  color?: string;
  align?: TextStyle['textAlign'];
  weight?: 'regular' | 'medium' | 'semibold' | 'bold' | 'black';
  style?: TextStyle;
}

export const StitchTypography: React.FC<StitchTypographyProps> = ({
  children,
  variant = 'body',
  color = StitchDesignSystem.colors.textPrimary,
  align = 'left',
  weight = 'regular',
  style,
}) => {
  const variantStyle =
    variant === 'hero'
      ? styles.textHero
      : variant === 'h1'
      ? styles.textH1
      : variant === 'h2'
      ? styles.textH2
      : variant === 'h3'
      ? styles.textH3
      : variant === 'bodySm'
      ? styles.textBodySm
      : variant === 'caption'
      ? styles.textCaption
      : styles.textBody;

  const family =
    weight === 'black'
      ? StitchDesignSystem.typography.fontFamily.black
      : weight === 'bold'
      ? StitchDesignSystem.typography.fontFamily.bold
      : weight === 'semibold'
      ? StitchDesignSystem.typography.fontFamily.semibold
      : weight === 'medium'
      ? StitchDesignSystem.typography.fontFamily.medium
      : StitchDesignSystem.typography.fontFamily.regular;

  return (
    <Text style={[variantStyle, { color, textAlign: align, fontFamily: family }, style]}>
      {children}
    </Text>
  );
};

interface StitchHeaderProps {
  title: string;
  onMenuPress?: () => void;
  onAvatarPress?: () => void;
  menuIcon?: keyof typeof Ionicons.glyphMap;
}

export const StitchHeader: React.FC<StitchHeaderProps> = ({
  title,
  onMenuPress,
  onAvatarPress,
  menuIcon = 'menu-outline',
}) => {
  return (
    <View style={styles.headerWrap}>
      <TouchableOpacity onPress={onMenuPress} style={styles.headerIconButton} disabled={!onMenuPress}>
        <Ionicons name={menuIcon} size={20} color={StitchDesignSystem.colors.primary} />
      </TouchableOpacity>

      <StitchTypography variant="h2" weight="black" color={StitchDesignSystem.colors.primary} style={styles.headerTitle}>
        {title}
      </StitchTypography>

      <TouchableOpacity onPress={onAvatarPress} style={styles.avatarButton} disabled={!onAvatarPress}>
        <Text style={styles.avatarInitials}>UJ</Text>
      </TouchableOpacity>
    </View>
  );
};

interface StitchGenrePillProps {
  label: string;
  selected?: boolean;
  onPress?: () => void;
}

export const StitchGenrePill: React.FC<StitchGenrePillProps> = ({ label, selected, onPress }) => {
  return (
    <TouchableOpacity
      activeOpacity={0.86}
      onPress={onPress}
      style={[styles.genrePill, selected && styles.genrePillSelected]}
      disabled={!onPress}
    >
      <StitchTypography
        variant="bodySm"
        weight={selected ? 'semibold' : 'medium'}
        color={selected ? StitchDesignSystem.colors.primary : StitchDesignSystem.colors.textSecondary}
      >
        {label}
      </StitchTypography>
    </TouchableOpacity>
  );
};

interface StitchStreamingBadgeProps {
  service: 'Netflix' | 'Prime Video';
}

export const StitchStreamingBadge: React.FC<StitchStreamingBadgeProps> = ({ service }) => {
  const isNetflix = service === 'Netflix';
  return (
    <View
      style={[
        styles.streamingBadge,
        {
          backgroundColor: isNetflix ? 'rgba(229, 9, 20, 0.1)' : 'rgba(0, 168, 225, 0.1)',
        },
      ]}
    >
      <StitchTypography
        variant="caption"
        weight="bold"
        color={isNetflix ? StitchDesignSystem.colors.netflix : StitchDesignSystem.colors.primeVideo}
      >
        {isNetflix ? 'N' : 'P'}
      </StitchTypography>
    </View>
  );
};

interface StitchMovieHeroProps {
  title: string;
  subtitle: string;
  genres: string[];
  meta: string;
  onPress?: () => void;
}

export const StitchMovieHero: React.FC<StitchMovieHeroProps> = ({ title, subtitle, genres, meta, onPress }) => {
  return (
    <TouchableOpacity activeOpacity={0.92} onPress={onPress} style={styles.heroCard}>
      <View style={styles.heroPosterPlaceholder}>
        <Text style={styles.heroPosterText}>Poster</Text>
      </View>
      <View style={styles.heroOverlay} />
      <View style={styles.heroContent}>
        <StitchTypography variant="h1" weight="semibold" color={StitchDesignSystem.colors.textInverse}>
          {title}
        </StitchTypography>
        <StitchTypography variant="body" color={'#E9ECEF'} style={styles.heroSubtitle}>
          {subtitle}
        </StitchTypography>
        <View style={styles.heroGenresRow}>
          {genres.map((genre) => (
            <View key={genre} style={styles.heroGenreBadge}>
              <StitchTypography variant="caption" color={StitchDesignSystem.colors.textInverse}>
                {genre}
              </StitchTypography>
            </View>
          ))}
        </View>
        <StitchTypography variant="bodySm" color={'#E9ECEF'} style={styles.heroMeta}>
          {meta}
        </StitchTypography>
      </View>
    </TouchableOpacity>
  );
};

interface StitchRatingStarsProps {
  rating: number;
  max?: number;
  onRate?: (value: number) => void;
}

export const StitchRatingStars: React.FC<StitchRatingStarsProps> = ({ rating, max = 5, onRate }) => {
  return (
    <View style={styles.ratingRow}>
      {Array.from({ length: max }).map((_, index) => {
        const value = index + 1;
        return (
          <TouchableOpacity
            key={value}
            activeOpacity={0.8}
            onPress={() => onRate?.(value)}
            disabled={!onRate}
          >
            <Ionicons
              name={value <= rating ? 'star' : 'star-outline'}
              size={20}
              color={value <= rating ? StitchDesignSystem.colors.accent : StitchDesignSystem.colors.borderStrong}
            />
          </TouchableOpacity>
        );
      })}
    </View>
  );
};

interface StitchLoadingProps {
  label?: string;
}

export const StitchLoading: React.FC<StitchLoadingProps> = ({ label = 'Loading...' }) => {
  return (
    <View style={styles.loadingWrap}>
      <ActivityIndicator color={StitchDesignSystem.colors.primary} size="large" />
      <StitchTypography variant="body" color={StitchDesignSystem.colors.textSecondary} style={styles.loadingLabel}>
        {label}
      </StitchTypography>
    </View>
  );
};

const styles = StyleSheet.create({
  buttonBase: {
    minHeight: 52,
    borderRadius: StitchDesignSystem.radius.md,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: StitchDesignSystem.spacing.xl,
    ...StitchDesignSystem.shadows.subtle,
  },
  buttonPrimary: {
    backgroundColor: StitchDesignSystem.colors.primary,
  },
  buttonSecondary: {
    backgroundColor: StitchDesignSystem.colors.accent,
  },
  buttonOutline: {
    backgroundColor: StitchDesignSystem.colors.surface,
    borderWidth: 2,
    borderColor: StitchDesignSystem.colors.primary,
  },
  buttonGhost: {
    backgroundColor: 'transparent',
    shadowOpacity: 0,
    elevation: 0,
  },
  buttonDisabled: {
    opacity: 0.58,
  },
  fullWidth: {
    width: '100%',
  },
  buttonText: {
    fontSize: StitchDesignSystem.typography.fontSize.base,
    fontFamily: StitchDesignSystem.typography.fontFamily.semibold,
  },
  buttonTextLight: {
    color: StitchDesignSystem.colors.textInverse,
  },
  buttonTextDark: {
    color: StitchDesignSystem.colors.primary,
  },
  card: {
    backgroundColor: StitchDesignSystem.colors.surface,
    borderRadius: StitchDesignSystem.radius.lg,
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.border,
    ...StitchDesignSystem.shadows.card,
  },
  textHero: {
    fontSize: StitchDesignSystem.typography.fontSize.hero,
    lineHeight: StitchDesignSystem.typography.lineHeight.hero,
    letterSpacing: StitchDesignSystem.typography.letterSpacing.tight,
  },
  textH1: {
    fontSize: StitchDesignSystem.typography.fontSize.xxxl,
    lineHeight: StitchDesignSystem.typography.lineHeight.xxxl,
  },
  textH2: {
    fontSize: StitchDesignSystem.typography.fontSize.xxl,
    lineHeight: StitchDesignSystem.typography.lineHeight.xxl,
  },
  textH3: {
    fontSize: StitchDesignSystem.typography.fontSize.xl,
    lineHeight: StitchDesignSystem.typography.lineHeight.xl,
  },
  textBody: {
    fontSize: StitchDesignSystem.typography.fontSize.base,
    lineHeight: StitchDesignSystem.typography.lineHeight.base,
  },
  textBodySm: {
    fontSize: StitchDesignSystem.typography.fontSize.sm,
    lineHeight: StitchDesignSystem.typography.lineHeight.sm,
  },
  textCaption: {
    fontSize: StitchDesignSystem.typography.fontSize.xs,
    lineHeight: StitchDesignSystem.typography.lineHeight.xs,
  },
  headerWrap: {
    height: 64,
    borderBottomWidth: 1,
    borderBottomColor: '#EFF1F5',
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: StitchDesignSystem.spacing.base,
  },
  headerTitle: {
    letterSpacing: StitchDesignSystem.typography.letterSpacing.tight,
  },
  headerIconButton: {
    width: 36,
    height: 36,
    borderRadius: StitchDesignSystem.radius.full,
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarButton: {
    width: 34,
    height: 34,
    borderRadius: StitchDesignSystem.radius.full,
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.borderStrong,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: StitchDesignSystem.colors.surfaceMuted,
  },
  avatarInitials: {
    color: StitchDesignSystem.colors.primary,
    fontFamily: StitchDesignSystem.typography.fontFamily.bold,
    fontSize: 12,
  },
  genrePill: {
    borderRadius: StitchDesignSystem.radius.full,
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.borderStrong,
    backgroundColor: StitchDesignSystem.colors.surface,
    paddingHorizontal: StitchDesignSystem.spacing.md,
    paddingVertical: StitchDesignSystem.spacing.xs,
  },
  genrePillSelected: {
    borderColor: StitchDesignSystem.colors.primary,
    backgroundColor: StitchDesignSystem.colors.primarySoft,
  },
  streamingBadge: {
    width: 40,
    height: 40,
    borderRadius: StitchDesignSystem.radius.full,
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroCard: {
    borderRadius: StitchDesignSystem.radius.xl,
    overflow: 'hidden',
    minHeight: 400,
    backgroundColor: '#202A3A',
    ...StitchDesignSystem.shadows.hero,
  },
  heroPosterPlaceholder: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#2E3F5D',
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroPosterText: {
    color: 'rgba(255,255,255,0.45)',
    fontFamily: StitchDesignSystem.typography.fontFamily.medium,
    fontSize: 18,
    textTransform: 'uppercase',
    letterSpacing: 2,
  },
  heroOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: StitchDesignSystem.colors.overlayDark,
  },
  heroContent: {
    flex: 1,
    justifyContent: 'flex-end',
    paddingHorizontal: StitchDesignSystem.spacing.xl,
    paddingVertical: StitchDesignSystem.spacing.xxl,
    gap: StitchDesignSystem.spacing.sm,
  },
  heroSubtitle: {
    opacity: 0.9,
  },
  heroGenresRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: StitchDesignSystem.spacing.sm,
  },
  heroGenreBadge: {
    borderRadius: StitchDesignSystem.radius.full,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.2)',
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: StitchDesignSystem.spacing.md,
    paddingVertical: StitchDesignSystem.spacing.xs,
  },
  heroMeta: {
    marginTop: StitchDesignSystem.spacing.xs,
    opacity: 0.9,
  },
  ratingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: StitchDesignSystem.spacing.xs,
  },
  loadingWrap: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: StitchDesignSystem.spacing.xxl,
  },
  loadingLabel: {
    marginTop: StitchDesignSystem.spacing.base,
  },
});
