import { Dimensions, Platform } from 'react-native';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

export const StitchDesignSystem = {
  colors: {
    primary: '#173B6C',
    primarySoft: '#D6E3FF',
    secondary: '#22A3F1',
    accent: '#FF6A3D',
    background: '#F4F3F8',
    surface: '#FFFFFF',
    surfaceMuted: '#F8F9FA',
    border: '#E3E2E7',
    borderStrong: '#C3C6D0',
    textPrimary: '#1A1C1F',
    textSecondary: '#43474F',
    textMuted: '#747780',
    textInverse: '#FFFFFF',
    shadow: '#000000',
    success: '#28A745',
    warning: '#FFC107',
    danger: '#DC3545',
    info: '#17A2B8',
    netflix: '#E50914',
    primeVideo: '#00A8E1',
    overlayDark: 'rgba(33, 37, 41, 0.72)',
    overlaySoft: 'rgba(255, 255, 255, 0.15)',
  },
  spacing: {
    xxs: 2,
    xs: 4,
    sm: 8,
    md: 12,
    base: 16,
    lg: 20,
    xl: 24,
    xxl: 32,
    xxxl: 40,
  },
  radius: {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 22,
    full: 999,
  },
  typography: {
    fontFamily: {
      regular: Platform.select({
        ios: 'BeVietnamPro-Regular',
        android: 'BeVietnamPro-Regular',
        default: 'System',
      }),
      medium: Platform.select({
        ios: 'BeVietnamPro-Medium',
        android: 'BeVietnamPro-Medium',
        default: 'System',
      }),
      semibold: Platform.select({
        ios: 'BeVietnamPro-SemiBold',
        android: 'BeVietnamPro-SemiBold',
        default: 'System',
      }),
      bold: Platform.select({
        ios: 'BeVietnamPro-Bold',
        android: 'BeVietnamPro-Bold',
        default: 'System',
      }),
      black: Platform.select({
        ios: 'BeVietnamPro-Black',
        android: 'BeVietnamPro-Black',
        default: 'System',
      }),
    },
    fontSize: {
      xs: 12,
      sm: 14,
      base: 16,
      lg: 18,
      xl: 20,
      xxl: 24,
      xxxl: 30,
      hero: 36,
    },
    lineHeight: {
      xs: 16,
      sm: 20,
      base: 24,
      lg: 27,
      xl: 30,
      xxl: 36,
      xxxl: 40,
      hero: 45,
    },
    letterSpacing: {
      tight: -0.6,
      normal: 0,
      wide: 0.6,
      wider: 0.9,
    },
  },
  shadows: {
    subtle: {
      shadowColor: '#000000',
      shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.08,
      shadowRadius: 2,
      elevation: 1,
    },
    card: {
      shadowColor: '#000000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.08,
      shadowRadius: 10,
      elevation: 3,
    },
    hero: {
      shadowColor: '#000000',
      shadowOffset: { width: 0, height: 8 },
      shadowOpacity: 0.18,
      shadowRadius: 16,
      elevation: 8,
    },
  },
  layout: {
    screenWidth,
    screenHeight,
    contentMaxWidth: 430,
    bottomTabHeight: Platform.OS === 'ios' ? 88 : 72,
  },
};

export const stitchCommonStyles = {
  safeArea: {
    flex: 1,
    backgroundColor: StitchDesignSystem.colors.background,
  },
  screenContainer: {
    flex: 1,
    backgroundColor: StitchDesignSystem.colors.background,
  },
  contentContainer: {
    paddingHorizontal: StitchDesignSystem.spacing.base,
  },
};

export default StitchDesignSystem;
