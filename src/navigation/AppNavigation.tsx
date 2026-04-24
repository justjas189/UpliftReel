import React from 'react';
import { Platform, StatusBar, StyleSheet, View } from 'react-native';
import { DefaultTheme, NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { Ionicons } from '@expo/vector-icons';

import { useAppContext } from '../context/AppContext';
import { StitchDesignSystem } from '../styles/StitchDesignSystem';

import EnhancedHomeScreen from '../screens/EnhancedHomeScreen';
import EnhancedMoodInputScreen from '../screens/EnhancedMoodInputScreen';
import EnhancedPreferencesScreen from '../screens/EnhancedPreferencesScreen';
import EnhancedHistoryScreen from '../screens/EnhancedHistoryScreen';
import MovieDetailsScreen from '../screens/MovieDetailsScreen';
import ProfileScreen from '../screens/ProfileScreen';
import SettingsScreen from '../screens/SettingsScreen';
import { StitchLoading } from '../components/StitchUI';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

const sharedStackOptions = {
  headerShown: false,
  cardStyle: {
    backgroundColor: StitchDesignSystem.colors.background,
  },
};

const HomeStack = () => (
  <Stack.Navigator screenOptions={sharedStackOptions}>
    <Stack.Screen name="HomeMain" component={EnhancedHomeScreen} />
    <Stack.Screen name="History" component={EnhancedHistoryScreen} />
    <Stack.Screen name="MovieDetails" component={MovieDetailsScreen} />
    <Stack.Screen name="Profile" component={ProfileScreen} />
    <Stack.Screen name="Settings" component={SettingsScreen} />
  </Stack.Navigator>
);

const MoodStack = () => (
  <Stack.Navigator screenOptions={sharedStackOptions}>
    <Stack.Screen name="MoodMain" component={EnhancedMoodInputScreen} />
    <Stack.Screen name="History" component={EnhancedHistoryScreen} />
    <Stack.Screen name="MovieDetails" component={MovieDetailsScreen} />
    <Stack.Screen name="Profile" component={ProfileScreen} />
    <Stack.Screen name="Settings" component={SettingsScreen} />
  </Stack.Navigator>
);

const PreferencesStack = () => (
  <Stack.Navigator screenOptions={sharedStackOptions}>
    <Stack.Screen name="PreferencesMain" component={EnhancedPreferencesScreen} />
    <Stack.Screen name="History" component={EnhancedHistoryScreen} />
    <Stack.Screen name="MovieDetails" component={MovieDetailsScreen} />
    <Stack.Screen name="Profile" component={ProfileScreen} />
    <Stack.Screen name="Settings" component={SettingsScreen} />
  </Stack.Navigator>
);

const TabNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarHideOnKeyboard: true,
        tabBarActiveTintColor: StitchDesignSystem.colors.primary,
        tabBarInactiveTintColor: StitchDesignSystem.colors.textMuted,
        tabBarLabelStyle: {
          fontFamily: StitchDesignSystem.typography.fontFamily.bold,
          fontSize: 12,
          paddingBottom: 1,
        },
        tabBarStyle: {
          backgroundColor: StitchDesignSystem.colors.surface,
          borderTopColor: '#EFF1F5',
          borderTopWidth: 1,
          height: StitchDesignSystem.layout.bottomTabHeight,
          paddingTop: 10,
          paddingBottom: Platform.OS === 'ios' ? 24 : 10,
          position: 'absolute',
          ...StitchDesignSystem.shadows.card,
        },
        tabBarIcon: ({ focused, color, size }) => {
          const iconName =
            route.name === 'HomeTab'
              ? focused
                ? 'home'
                : 'home-outline'
              : route.name === 'MoodTab'
              ? focused
                ? 'happy'
                : 'happy-outline'
              : focused
              ? 'options'
              : 'options-outline';

          return <Ionicons name={iconName as any} size={size} color={color} />;
        },
      })}
    >
      <Tab.Screen
        name="HomeTab"
        component={HomeStack}
        options={{
          tabBarLabel: 'Home',
          tabBarAccessibilityLabel: 'Home tab',
        }}
      />
      <Tab.Screen
        name="MoodTab"
        component={MoodStack}
        options={{
          tabBarLabel: 'Mood',
          tabBarAccessibilityLabel: 'Mood tab',
        }}
      />
      <Tab.Screen
        name="PreferencesTab"
        component={PreferencesStack}
        options={{
          tabBarLabel: 'Preferences',
          tabBarAccessibilityLabel: 'Preferences tab',
        }}
      />
    </Tab.Navigator>
  );
};

export const AppNavigation: React.FC = () => {
  const { state } = useAppContext();

  const navigationTheme = {
    ...DefaultTheme,
    colors: {
      ...DefaultTheme.colors,
      primary: StitchDesignSystem.colors.primary,
      background: StitchDesignSystem.colors.background,
      card: StitchDesignSystem.colors.surface,
      text: StitchDesignSystem.colors.textPrimary,
      border: StitchDesignSystem.colors.border,
    },
  };

  if (state.isLoading && !state.userPreferences) {
    return (
      <View style={styles.loadingRoot}>
        <StatusBar barStyle="dark-content" backgroundColor={StitchDesignSystem.colors.background} />
        <StitchLoading label="Preparing Uplift Reel..." />
      </View>
    );
  }

  return (
    <>
      <StatusBar barStyle="dark-content" backgroundColor={StitchDesignSystem.colors.background} />
      <NavigationContainer theme={navigationTheme}>
        <TabNavigator />
      </NavigationContainer>
    </>
  );
};

const styles = StyleSheet.create({
  loadingRoot: {
    flex: 1,
    backgroundColor: StitchDesignSystem.colors.background,
  },
});

export default AppNavigation;
