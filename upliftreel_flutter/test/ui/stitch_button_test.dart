import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upliftreel/ui/core/theme/stitch_theme.dart';
import 'package:upliftreel/ui/core/widgets/stitch_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget harness(Widget child) {
    return MaterialApp(
      theme: StitchTheme.dark(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('tap fires callback and light haptic', (tester) async {
    final haptics = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      },
    );

    var taps = 0;
    await tester.pumpWidget(harness(
      StitchButton(label: 'Watched it', onPressed: () => taps++),
    ));

    await tester.tap(find.text('Watched it'));
    await tester.pump();

    expect(taps, 1);
    expect(haptics, ['HapticFeedbackType.lightImpact']);
  });

  testWidgets('press scales down, release restores', (tester) async {
    await tester.pumpWidget(harness(
      StitchButton(label: 'Press me', onPressed: () {}),
    ));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Press me')),
    );
    await tester.pump();

    AnimatedScale scaleOf() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scaleOf().scale, 0.97);

    await gesture.up();
    await tester.pump();
    expect(scaleOf().scale, 1.0);
  });

  testWidgets('disabled and loading block taps', (tester) async {
    var taps = 0;

    await tester.pumpWidget(harness(
      const StitchButton(label: 'Disabled'),
    ));
    await tester.tap(find.text('Disabled'), warnIfMissed: false);
    expect(taps, 0);

    await tester.pumpWidget(harness(
      StitchButton(label: 'Loading', loading: true, onPressed: () => taps++),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading'), findsNothing);
    await tester.tap(find.byType(StitchButton), warnIfMissed: false);
    expect(taps, 0);
  });
}
