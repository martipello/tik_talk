import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tik_talk/app.dart';
import 'package:tik_talk/core/services/shared_preferences_provider.dart';

void main() {
  testWidgets('TikTalk app shows the timer tab on launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const TikTalkApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TikTalk'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
