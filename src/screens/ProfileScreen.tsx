import React from 'react';
import { ScrollView, StyleSheet, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { StitchDesignSystem, stitchCommonStyles } from '../styles/StitchDesignSystem';
import {
  StitchButton,
  StitchCard,
  StitchHeader,
  StitchTypography,
} from '../components/StitchUI';

interface ProfileScreenProps {
  navigation: any;
}

const ProfileScreen: React.FC<ProfileScreenProps> = ({ navigation }) => {
  return (
    <SafeAreaView style={stitchCommonStyles.safeArea}>
      <StitchHeader
        title="Profile"
        menuIcon="chevron-back"
        onMenuPress={() => navigation.goBack()}
      />

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <StitchCard style={styles.profileCard}>
          <View style={styles.avatarLarge}>
            <StitchTypography variant="h2" weight="bold" color={StitchDesignSystem.colors.primary}>
              UJ
            </StitchTypography>
          </View>
          <StitchTypography variant="h2" weight="semibold" align="center">
            Uplift Reel Viewer
          </StitchTypography>
          <StitchTypography variant="body" color={StitchDesignSystem.colors.textSecondary} align="center">
            Your personalized movie journey.
          </StitchTypography>
        </StitchCard>

        <View style={styles.quickActions}>
          <TouchableOpacity style={styles.quickActionItem} onPress={() => navigation.navigate('PreferencesTab')}>
            <Ionicons name="options-outline" size={20} color={StitchDesignSystem.colors.primary} />
            <StitchTypography variant="body" weight="medium">
              Movie Preferences
            </StitchTypography>
          </TouchableOpacity>

          <TouchableOpacity style={styles.quickActionItem} onPress={() => navigation.navigate('History')}>
            <Ionicons name="time-outline" size={20} color={StitchDesignSystem.colors.primary} />
            <StitchTypography variant="body" weight="medium">
              Watch History
            </StitchTypography>
          </TouchableOpacity>

          <TouchableOpacity style={styles.quickActionItem} onPress={() => navigation.navigate('Settings')}>
            <Ionicons name="settings-outline" size={20} color={StitchDesignSystem.colors.primary} />
            <StitchTypography variant="body" weight="medium">
              App Settings
            </StitchTypography>
          </TouchableOpacity>
        </View>

        <StitchButton
          title="Back To Home"
          variant="outline"
          onPress={() => navigation.navigate('HomeTab')}
          fullWidth
        />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  content: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.base,
  },
  profileCard: {
    padding: StitchDesignSystem.spacing.xxl,
    alignItems: 'center',
    gap: StitchDesignSystem.spacing.sm,
  },
  avatarLarge: {
    width: 74,
    height: 74,
    borderRadius: StitchDesignSystem.radius.full,
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.borderStrong,
    backgroundColor: StitchDesignSystem.colors.primarySoft,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: StitchDesignSystem.spacing.sm,
  },
  quickActions: {
    gap: StitchDesignSystem.spacing.sm,
  },
  quickActionItem: {
    borderWidth: 1,
    borderColor: StitchDesignSystem.colors.border,
    backgroundColor: StitchDesignSystem.colors.surface,
    borderRadius: StitchDesignSystem.radius.md,
    paddingVertical: StitchDesignSystem.spacing.base,
    paddingHorizontal: StitchDesignSystem.spacing.base,
    flexDirection: 'row',
    alignItems: 'center',
    gap: StitchDesignSystem.spacing.sm,
    ...StitchDesignSystem.shadows.subtle,
  },
});

export default ProfileScreen;
