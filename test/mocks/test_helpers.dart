import 'package:async_redux/async_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xplore/application/redux/states/app_state.dart';
import 'package:xplore/domain/core/value_objects/app_widget_keys.dart';
import 'package:xplore/presentation/routes/route_generator.dart';

/// [buildTestWidget] is a widget wrapper used for testing
/// It wraps the widget with a `StoreProvider`, `AppWrapperBase`, `MaterialApp` and a `Scaffold`
/// Helps to avoid repetition across test files requiring the above widgets
///
/// The function will create a store for you if you don't provide one
Future<void> buildTestWidget({
  required WidgetTester tester,
  required Widget widget,
  Store<AppState>? store,
  List<NavigatorObserver>? navigatorObservers,
  Widget? endDrawer,
  Duration? duration,
}) async {
  final Store<AppState> _store =
      Store<AppState>(initialState: AppState.initial());

  NavigateAction.setNavigatorKey(globalAppNavigatorKey);

  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store ?? _store,
      child: MaterialApp(
        onGenerateRoute: AppRouterGenerator.generateRoute,
        navigatorKey: globalAppNavigatorKey,
        navigatorObservers: navigatorObservers ?? <NavigatorObserver>[],
        home: Scaffold(
          endDrawer: endDrawer,
          body: widget,
        ),
      ),
    ),
    duration,
  );
}

StoreTester<AppState> createStoreTester() {
  final Store<AppState> store =
      Store<AppState>(initialState: AppState.initial());
  return StoreTester<AppState>.from(
    store,
    testInfoPrinter: (TestInfo<dynamic> testInfo) {},
  );
}

Type typeOf<T>() => T;
