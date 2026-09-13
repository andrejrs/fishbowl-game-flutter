import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [screen] as if it had been navigated to with the given route
/// [arguments], so that `ModalRoute.of(context)!.settings.arguments` works.
///
/// [routes] can be used to register additional named routes the screen may
/// navigate to; each named route below renders a simple placeholder that
/// echoes the arguments it was pushed with as text, so tests can assert on
/// navigation without pulling in the full downstream screen.
Future<void> pumpScreenWithArgs(
  WidgetTester tester, {
  required Widget screen,
  required Map<String, dynamic> arguments,
  List<String> placeholderRoutes = const [],
  List<NavigatorObserver> observers = const [],
}) async {
  // A sentinel route name (rather than '/') keeps the screen-under-test's
  // initial route from colliding with a real app route named '/', which
  // matters when the screen itself navigates back to '/'.
  const initialRouteName = '/__test_root__';
  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: observers,
      onGenerateRoute: (settings) {
        if (settings.name == initialRouteName) {
          return MaterialPageRoute(
            settings: RouteSettings(arguments: arguments),
            builder: (_) => screen,
          );
        }
        if (placeholderRoutes.contains(settings.name)) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => Scaffold(
              body: Text('placeholder:${settings.name}:${settings.arguments}'),
            ),
          );
        }
        return null;
      },
      initialRoute: initialRouteName,
    ),
  );
}

/// Enlarges the test surface so that dynamically-growing lists (adding
/// players, adding words, ...) don't get culled from hit-testing by
/// [ListView]'s viewport/sliver culling, which would otherwise make
/// `find.byType` miss widgets that have scrolled out of a default-sized
/// (~800x600) test window. Automatically restored via [addTearDown].
void useTallTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Finds an [ElevatedButton] (including the `ElevatedButton.icon` variant,
/// whose private implementation class isn't matched by `find.byType`)
/// containing the given [text].
Finder elevatedButtonWithText(String text) => find.ancestor(
      of: find.text(text),
      matching: find.bySubtype<ElevatedButton>(),
    );

/// Finds an [ElevatedButton] (including the `ElevatedButton.icon` variant)
/// containing the given [icon].
Finder elevatedButtonWithIcon(IconData icon) => find.ancestor(
      of: find.byIcon(icon),
      matching: find.bySubtype<ElevatedButton>(),
    );

/// Records the names and arguments of every route pushed through it.
class RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  final List<Route<dynamic>> replaced = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) replaced.add(newRoute);
  }
}
