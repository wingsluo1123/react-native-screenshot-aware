import { useCallback, useState } from 'react';
import { Platform, Pressable, StyleSheet, Text, View } from 'react-native';
import { useScreenshotAware } from 'react-native-screenshot-aware';

export default function App() {
  const [eventCount, setEventCount] = useState(0);
  const [lastEventAt, setLastEventAt] = useState<string | null>(null);

  const handleCapture = useCallback(() => {
    console.log('[App] handleCapture called - screenshot detected!');
    setEventCount((count) => count + 1);
    setLastEventAt(new Date().toLocaleTimeString());
    console.log('A screenshot or screen-capture event was detected.');
  }, []);

  console.log('[App] Component rendering, eventCount:', eventCount);
  useScreenshotAware(handleCapture);
  console.log('[App] useScreenshotAware hook registered');

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Screenshot Aware</Text>
      <Text style={styles.platform}>Platform: {Platform.OS}</Text>
      <Text style={styles.count}>{eventCount}</Text>
      <Text style={styles.label}>capture events detected</Text>
      <Text style={styles.lastEvent}>
        {lastEventAt
          ? `Last event: ${lastEventAt}`
          : 'Take a screenshot to test'}
      </Text>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel="Reset capture event count"
        style={styles.resetButton}
        onPress={() => {
          setEventCount(0);
          setLastEventAt(null);
        }}
      >
        <Text style={styles.resetButtonText}>Reset count</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#f7f7f7',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#111827',
  },
  platform: {
    marginTop: 8,
    color: '#6b7280',
  },
  count: {
    marginTop: 32,
    fontSize: 64,
    fontWeight: '700',
    color: '#2563eb',
  },
  label: {
    marginTop: 4,
    color: '#374151',
  },
  lastEvent: {
    marginTop: 24,
    color: '#4b5563',
  },
  resetButton: {
    marginTop: 24,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 6,
    backgroundColor: '#111827',
  },
  resetButtonText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
