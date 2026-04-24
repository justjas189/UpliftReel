import React, { useState } from 'react';
import { ScrollView, StyleSheet, Switch, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StitchDesignSystem, stitchCommonStyles } from '../styles/StitchDesignSystem';
import {
  StitchButton,
  StitchCard,
  StitchHeader,
  StitchTypography,
} from '../components/StitchUI';

interface SettingsScreenProps {
  navigation: any;
}

const SettingsScreen: React.FC<SettingsScreenProps> = ({ navigation }) => {
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [dailyDigestEnabled, setDailyDigestEnabled] = useState(true);

  return (
    <SafeAreaView style={stitchCommonStyles.safeArea}>
      <StitchHeader
        title="Settings"
        menuIcon="chevron-back"
        onMenuPress={() => navigation.goBack()}
      />

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <StitchCard style={styles.settingCard}>
          <View style={styles.row}>
            <View style={styles.textWrap}>
              <StitchTypography variant="h3" weight="semibold">
                Daily Notifications
              </StitchTypography>
              <StitchTypography variant="bodySm" color={StitchDesignSystem.colors.textSecondary}>
                Get your recommendation alert each day.
              </StitchTypography>
            </View>
            <Switch
              value={notificationsEnabled}
              onValueChange={setNotificationsEnabled}
              thumbColor={notificationsEnabled ? StitchDesignSystem.colors.primary : '#E3E2E7'}
              trackColor={{ false: '#C3C6D0', true: '#9CB7EA' }}
            />
          </View>
        </StitchCard>

        <StitchCard style={styles.settingCard}>
          <View style={styles.row}>
            <View style={styles.textWrap}>
              <StitchTypography variant="h3" weight="semibold">
                Weekly Digest
              </StitchTypography>
              <StitchTypography variant="bodySm" color={StitchDesignSystem.colors.textSecondary}>
                Recap your top recommendations each week.
              </StitchTypography>
            </View>
            <Switch
              value={dailyDigestEnabled}
              onValueChange={setDailyDigestEnabled}
              thumbColor={dailyDigestEnabled ? StitchDesignSystem.colors.primary : '#E3E2E7'}
              trackColor={{ false: '#C3C6D0', true: '#9CB7EA' }}
            />
          </View>
        </StitchCard>

        <StitchCard style={styles.infoCard}>
          <StitchTypography variant="body" color={StitchDesignSystem.colors.textSecondary}>
            Version 1.0.0
          </StitchTypography>
          <StitchTypography variant="bodySm" color={StitchDesignSystem.colors.textMuted}>
            Final assets and advanced settings controls are coming in the next pass.
          </StitchTypography>
        </StitchCard>

        <StitchButton
          title="Back To Profile"
          variant="outline"
          onPress={() => navigation.navigate('Profile')}
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
  settingCard: {
    padding: StitchDesignSystem.spacing.base,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: StitchDesignSystem.spacing.base,
  },
  textWrap: {
    flex: 1,
    gap: StitchDesignSystem.spacing.xs,
  },
  infoCard: {
    padding: StitchDesignSystem.spacing.base,
    gap: StitchDesignSystem.spacing.xs,
  },
});

export default SettingsScreen;
