// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:shamiri/application/redux/states/app_state.dart';
import 'package:shamiri/application/singletons/button_status.dart';
import 'package:shamiri/application/singletons/initial_route.dart';
import 'package:shamiri/domain/routes/routes.dart';
import 'package:shamiri/domain/value_objects/app_enums.dart';
import 'package:shamiri/domain/value_objects/app_event_strings.dart';
import 'package:shamiri/domain/value_objects/app_strings.dart';

final Logger logger = Logger();

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

  logger.w(firebaseConnectSuccess);
}

/// Gets initial route based on the userState status
Future<String> getInitialRoute({
  required AppState state,
}) async {
  final AuthStatus tokenStatus = await getAuthStatus(
    currentStore: state,
  );

  switch (tokenStatus) {
    case AuthStatus.init:
      return landingPageRoute;
    case AuthStatus.requiresLogin:
      return phoneInputPageRoute;
    case AuthStatus.okay:
      return dashPageRoute;
    default:
      return landingPageRoute;
  }
}

Future<AuthStatus> getAuthStatus({
  required AppState currentStore,
}) async {
  final bool hasDoneTour = currentStore.userState?.hasDoneTour ?? false;
  final bool signedIn = currentStore.userState?.isSignedIn ?? false;
  final bool isUIDPresent = (currentStore.userState?.uid != null);
  //todo: Add condition for 12hr Session Expiration

  if (hasDoneTour == true) {
    if (signedIn == true && isUIDPresent) {
      return AuthStatus.okay;
    } else {
      return AuthStatus.requiresLogin;
    }
  } else {
    return AuthStatus.init;
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

Color evaluateButtonStatus(ButtonStatus status) {
  return status.color;
}

void insertText(String myText, TextEditingController controller) {
  final text = controller.text;
  final textSelection = controller.selection;
  final newText = text.replaceRange(
    textSelection.start,
    textSelection.end,
    myText,
  );
  final myTextLength = myText.length;
  controller.text = newText;
  controller.selection = textSelection.copyWith(
    baseOffset: textSelection.start + myTextLength,
    extentOffset: textSelection.start + myTextLength,
  );
}

void backspace(TextEditingController controller) {
  final text = controller.text;
  final textSelection = controller.selection;
  final selectionLength = textSelection.end - textSelection.start;

  // There is a selection.
  if (selectionLength > 0) {
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      '',
    );
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: textSelection.start,
      extentOffset: textSelection.start,
    );
    return;
  }

  // The cursor is at the beginning.
  if (textSelection.start == 0) {
    return;
  }

  // Delete the previous character
  final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
  final offset = isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
  final newStart = textSelection.start - offset;
  final newEnd = textSelection.start;
  final newText = text.replaceRange(
    newStart,
    newEnd,
    '',
  );
  controller.text = newText;
  controller.selection = textSelection.copyWith(
    baseOffset: newStart,
    extentOffset: newStart,
  );
}

bool isUtf16Surrogate(int value) {
  return value & 0xF800 == 0xD800;
}

Future<bool> checkInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    //SaveOffSessionAnalytic
    return false;
  } else {
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
      //LogAnalytic (ConnectivityResult.wifi)
    } else {
      return true;
      //LogAnalytic
    }
  }
}

void validatePhone({
  String? v = '',
  required TextEditingController controller,
}) {
  final bool nullCheck = v!.isNotEmpty;
  final bool lengthCheck = (controller.text.length == 13);

  if (nullCheck && lengthCheck) {
    ButtonStatusStore().colorStream.add(ButtonStatus.neutral.color);
    ButtonStatusStore().statusStream.add(true);
  }
}

LoginProgressBtnStore phoneLoginProgressInstance = LoginProgressBtnStore();
InitialRouteStore appInitialRoute = InitialRouteStore();
VerifyProgressBtnStore otpProgressProgressInstance = VerifyProgressBtnStore();
