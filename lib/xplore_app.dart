// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:async_redux/async_redux.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Project imports:
import 'package:xplore/application/core/services/helpers.dart';
import 'package:xplore/application/redux/states/app_state.dart';
import 'package:xplore/application/redux/states/user_state.dart';
import 'package:xplore/application/singletons/initial_route.dart';
import 'package:xplore/domain/core/lifecycle_event_handler.dart';
import 'package:xplore/domain/routes/route_generator.dart';
import 'package:xplore/domain/routes/routes.dart';
import 'package:xplore/domain/value_objects/app_global_constants.dart';
import 'package:xplore/presentation/core/widgets/xplore_app_wrapper.dart';
import 'package:xplore/presentation/core/widgets/xplore_loader.dart';

class XploreApp extends StatefulWidget {
  const XploreApp({required this.store});

  final Store<AppState> store;

  @override
  _XploreAppState createState() => _XploreAppState();
}

class _XploreAppState extends State<XploreApp> with WidgetsBindingObserver {
  FirebaseApp xploreFirebaseApp = Firebase.app();
  InitialRouteStore appInitialRoute = InitialRouteStore();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Future<dynamic>.delayed(Duration.zero, () async {
        final UserState? userState = widget.store.state.userState;
        if (!(userState?.isSignedIn ?? false) && (userState?.uid != null)) {
          appInitialRoute.initialRoute.add(
            await getInitialRoute(state: widget.store.state),
          );
        } 
        else {
          appInitialRoute.initialRoute.add(dashPageRoute);
        }
        FlutterNativeSplash.remove();
      });
    });

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(
      LifecycleEventHandler(
        onResume: () => Future.value(),
        onSuspend: () => Future.value(),
        onChangeBrightness: () => Future.value(),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return XploreWrapper(
        store: widget.store,
        child: MaterialApp(
          debugShowCheckedModeBanner: !kReleaseMode,
          home: StreamBuilder<String>(
            stream: appInitialRoute.initialRoute.stream,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Scaffold(
                  body: Container(
                    child: Center(
                      child: XploreLoader(),
                    ),
                  ),
                );
              }

              return StoreProvider<AppState>(
                store: widget.store,
                child: StoreConnector<AppState, AppState>(
                    converter: (Store<AppState> store) => store.state,
                    builder: (BuildContext context, AppState state) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: !kReleaseMode,
                        navigatorKey: globalAppNavigatorKey,
                        navigatorObservers: <NavigatorObserver>[
                          FirebaseAnalyticsObserver(analytics: _analytics),
                        ],
                        initialRoute:
                            appInitialRoute.initialRoute.valueOrNull ??
                                landingPageRoute,
                        onGenerateRoute: AppRouterGenerator.generateRoute,
                      );
                    }),
              );
            },
          ),
        ));
  }
}
