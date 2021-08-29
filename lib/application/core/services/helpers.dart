import 'package:async_redux/async_redux.dart';
import 'package:debug_logger/debug_logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:xplore/application/redux/actions/phone_signup_action.dart';
import 'package:xplore/application/redux/actions/update_user_state_action.dart';
import 'package:xplore/application/redux/states/app_state.dart';
import 'package:xplore/domain/value_objects/app_enums.dart';
import 'package:xplore/domain/value_objects/app_event_strings.dart';
import 'package:xplore/domain/value_objects/app_strings.dart';
import 'package:xplore/presentation/core/widgets/xplore_snackbar.dart';
import 'package:xplore/presentation/routes/routes.dart';

/// Utility method for sending initial event to [FirebaseAnalytics]
Future<void> sendInitialAnalyticsEvent({
  required FirebaseAnalytics analytics,
}) async {
  await analytics.logAppOpen();

  await analytics.logEvent(
    name: initialEvent,
    parameters: <String, dynamic>{
      eventText: initialEventSuccess,
    },
  );

  await analytics.setAnalyticsCollectionEnabled(true);

  await analytics.setCurrentScreen(
    screenName: rootPage,
  );

  DebugLogger.warning(firebaseConnectSuccess);
}

/// Gets initial route based on the userState status
Future<String> getInitialRoute({
  required BuildContext context,
  required Store store,
}) async {
  final AuthStatus tokenStatus = await getAuthStatus(
    store: store,
    context: context,
  );

  switch (tokenStatus) {
    case AuthStatus.init:
      return onboardingPageRoute;
    case AuthStatus.requiresLogin:
      return loginPageRoute;
    case AuthStatus.okay:
      return homePageRoute;
    default:
      return landingPageRoute;
  }
}

Future<AuthStatus> getAuthStatus({
  required BuildContext context,
  required Store store,
}) async {
  final bool hasDoneTour = store.state.userState!.hasDoneTour ?? false;
  final bool signedIn = store.state.userState!.isSignedIn ?? false;

  if (hasDoneTour == true) {
    if (signedIn == true) {
      return AuthStatus.okay;
    } else {
      return AuthStatus.requiresLogin;
    }
  } else {
    return AuthStatus.init;
  }
}

/// Phone SignUp (register)
Future<void> signUp({
  required BuildContext context,
  required String phoneNumber,
  required bool areTermsAccepted,
  required GlobalKey<FormState> formKey,
}) async {
  if (formKey.currentState!.validate() && areTermsAccepted != false) {
    formKey.currentState!.save();

    StoreProvider.dispatch<AppState>(
      context,
      UpdateUserStateAction(areTermsAccepted: true),
    );

    await StoreProvider.dispatch<AppState>(
      context,
      PhoneSignupAction(
        context: context,
        phoneNumber: phoneNumber,
      ),
    );

    StoreProvider.dispatch<AppState>(
        context, NavigateAction.pushNamed(setPinPageRoute));
  } else {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        snackbar(
          content: termsAcceptPrompt,
          label: okText,
        ),
      );
  }
}

/// [Dismiss snackbar]
SnackBarAction dismissSnackBar(String text, Color color, BuildContext context) {
  return SnackBarAction(
    label: text,
    textColor: color,
    onPressed: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    },
  );
}
