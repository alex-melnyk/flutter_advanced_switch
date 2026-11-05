import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

Widget _app(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );

/// Horizontal thumb offset: -10 when off, +10 when on (default 50x30 switch).
double _thumbX(WidgetTester tester) => tester
    .widget<Transform>(find.descendant(
      of: find.byType(AdvancedSwitch),
      matching: find.byType(Transform),
    ))
    .transform
    .getTranslation()
    .x;

void main() {
  LeakTesting.enable();
  LeakTesting.settings =
      LeakTesting.settings.withIgnored(allNotGCed: true);

  testWidgets('a) mount and unmount without controller', (tester) async {
    await tester.pumpWidget(_app(AdvancedSwitch(onChanged: (_) {})));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('b) mount and unmount with external controller', (tester) async {
    final controller = ValueNotifier<bool>(true);
    await tester.pumpWidget(_app(AdvancedSwitch(controller: controller)));
    expect(_thumbX(tester), 10);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('c) parent rebuilds fire didUpdateWidget', (tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pumpWidget(_app(AdvancedSwitch(
        onChanged: (_) {},
        activeColor: Color(0xFF000000 + i),
      )));
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('d) swap controller null -> notifier -> null', (tester) async {
    final changes = <dynamic>[];
    final notifier = ValueNotifier<bool>(false);

    await tester.pumpWidget(_app(AdvancedSwitch(onChanged: changes.add)));
    await tester.tap(find.byType(AdvancedSwitch));
    await tester.pumpAndSettle();
    expect(changes, [true]);
    expect(_thumbX(tester), 10);

    // Swap to a notifier holding false: thumb must follow the new source.
    await tester.pumpWidget(_app(AdvancedSwitch(
      controller: notifier,
      onChanged: changes.add,
    )));
    expect(_thumbX(tester), -10);

    await tester.tap(find.byType(AdvancedSwitch));
    await tester.pumpAndSettle();
    expect(notifier.value, isTrue);
    expect(changes, [true, true]);
    expect(_thumbX(tester), 10);

    // Back to internal state; continues from the notifier's last value.
    await tester.pumpWidget(_app(AdvancedSwitch(onChanged: changes.add)));
    expect(_thumbX(tester), 10);
    await tester.tap(find.byType(AdvancedSwitch));
    await tester.pumpAndSettle();
    expect(changes, [true, true, false]);
    expect(_thumbX(tester), -10);
    // The parent's notifier must be detached and left alone.
    notifier.value = true;
    await tester.pump();
    expect(changes, [true, true, false]);

    await tester.pumpWidget(const SizedBox());
    notifier.dispose();
  });

  testWidgets('e) tap toggles value and animates thumb', (tester) async {
    final controller = ValueNotifier<bool>(false);
    final changes = <dynamic>[];
    await tester.pumpWidget(_app(AdvancedSwitch(
      controller: controller,
      onChanged: changes.add,
    )));
    expect(_thumbX(tester), -10);

    await tester.tap(find.byType(AdvancedSwitch));
    await tester.pump(); // starts the ticker
    await tester.pump(const Duration(milliseconds: 125));
    expect(_thumbX(tester), allOf(greaterThan(-10), lessThan(10)));
    await tester.pumpAndSettle();

    expect(controller.value, isTrue);
    expect(changes, [true]);
    expect(_thumbX(tester), 10);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
