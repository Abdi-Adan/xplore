// Flutter imports:
import 'package:async_redux/async_redux.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:xplore/application/redux/actions/update_user_state_action.dart';

// Project imports:
import 'package:xplore/application/redux/states/app_state.dart';
import 'package:xplore/application/singletons/button_status.dart';
import 'package:xplore/application/singletons/initial_route.dart';
import 'package:xplore/domain/routes/routes.dart';
import 'package:xplore/domain/value_objects/app_enums.dart';
import 'package:xplore/domain/value_objects/app_event_strings.dart';
import 'package:xplore/domain/value_objects/app_strings.dart';
import 'package:xplore/presentation/core/widgets/xplore_snackbar.dart';

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
      return loginPageRoute;
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

ProgressBtnStore phoneLoginProgressInstance = ProgressBtnStore();
FirebaseAuth globalFirebaseAuthInstance = FirebaseAuth.instance;
InitialRouteStore appInitialRoute = InitialRouteStore();

void verifyOtp(String otpText, BuildContext ctx, AppState store, {bool? isSignedIn}) async {
  final AuthCredential credential = PhoneAuthProvider.credential(
    verificationId: store.userState!.pinCodeVerificationID ?? '',
    smsCode: otpText,
  );
  final User? user = (await globalFirebaseAuthInstance.signInWithCredential(credential)).user;

  final User? currentUser = globalFirebaseAuthInstance.currentUser;
  assert(user!.uid == currentUser!.uid);

  if (user != null) {
    StoreProvider.dispatch(
        ctx,
        UpdateUserStateAction(
          isSignedIn: true,
          phoneNumber: user.phoneNumber,
          uid: user.uid,
        ));

    appInitialRoute.initialRoute.add(
      await getInitialRoute(state: store),
    );

    StoreProvider.dispatch<AppState>(
      ctx,
      NavigateAction.pushNamed(dashPageRoute),
    );
  } else {
    phoneLoginProgressInstance.btnStatus.add(ButtonState.fail);
    ScaffoldMessenger.of(ctx).showSnackBar(snackbar(
      content: "Sign In Failed",
    ));
  }
}
