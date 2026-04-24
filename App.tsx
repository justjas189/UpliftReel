/**
 * Uplift Reel - Daily Movie Recommendation App
 * Main Application Entry Point
 */

import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';

// Main Navigation
import { AppNavigation } from './src/navigation/AppNavigation';

// Context
import { AppProvider } from './src/context/AppContext';

const App: React.FC = () => {
  return (
    <SafeAreaProvider>
      <StatusBar style="auto" />
      <AppProvider>
        <AppNavigation />
      </AppProvider>
    </SafeAreaProvider>
  );
};

export default App;
