// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:async_redux/async_redux.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// Project imports:
import 'package:xplore/application/core/services/helpers.dart';
import 'package:xplore/application/core/themes/colors.dart';
import 'package:xplore/application/redux/states/app_state.dart';
import 'package:xplore/application/singletons/button_status.dart';
import 'package:xplore/domain/routes/routes.dart';
import 'package:xplore/domain/value_objects/app_spaces.dart';
import 'package:xplore/domain/value_objects/app_strings.dart';
import 'package:xplore/presentation/core/pages/xplore_numeric_keyboard.dart';
import 'package:xplore/presentation/onboarding/widgets/buttons/action_button.dart';
import 'package:xplore/presentation/onboarding/widgets/layout/keyboard_scaffold.dart';
import 'package:xplore/presentation/onboarding/widgets/login_title.dart';

// import 'package:xplore/application/redux/actions/update_user_state_action.dart';

class PhoneVerifyPage extends StatefulWidget {
  const PhoneVerifyPage({
    Key? key,
  }) : super(key: key);

  @override
  _PhoneVerifyPageState createState() => _PhoneVerifyPageState();
}

class _PhoneVerifyPageState extends State<PhoneVerifyPage> {
  TextEditingController otpPinCodeFieldController = new TextEditingController();
  StreamController errorAnimationController = StreamController();
  FocusNode otpPinCodeFocusNode = new FocusNode();
  ButtonStatusStore otpBtnStore = ButtonStatusStore();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        converter: (Store<AppState> store) => store.state,
        builder: (BuildContext context, AppState state) {
          return KeyboardScaffold(
            isSecondary: true,
            trailingActionIcon: Icons.textsms,
            widgets: [
              ...titles(
                context: context,
                title: 'Enter code sent \n',
                subtitle: 'to your number.',
                extraHeading: 'We sent it to ${state.userState!.phoneNumber}',
              ),
              vSize20SizedBox,
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Text(
                    "Enter 6 digits code",
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: PinCodeTextField(
                    autoFocus: true,
                    focusNode: otpPinCodeFocusNode,
                    useHapticFeedback: true,
                    hapticFeedbackTypes: HapticFeedbackTypes.vibrate,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.scale,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                      activeColor: XploreColors.deepBlue,
                      inactiveColor: XploreColors.orange,
                      inactiveFillColor: XploreColors.white,
                      selectedFillColor: XploreColors.white,
                      errorBorderColor: XploreColors.red,
                      selectedColor: XploreColors.orange,
                    ),
                    cursorColor: XploreColors.orange,
                    keyboardType: TextInputType.none,
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: XploreColors.white,
                    enableActiveFill: true,
                    controller: otpPinCodeFieldController,
                    onCompleted: (v) {
                      print("Completed");
                    },
                    onChanged: (value) {
                      setState(() {
                        otpPinCodeFieldController.text = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      print("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                    appContext: context,
                  ),
                ),
              ),
              vSize20SizedBox,
              ActionButton(
                widgetText: nextText,
                nextRoute: dashPageRoute,
                colorStream: otpBtnStore.colorStream,
                statusStream: otpBtnStore.statusStream,
                onTapCallback: () {
                  verifyOtp(otpPinCodeFieldController.text, context,
                      isSignedIn: state.userState!.isSignedIn);
                },
              ),
              vSize30SizedBox,
              Container(
                child: XploreNumericKeyboard(
                  onKeyboardTap: (String text) {
                    setState(() {
                      insertText(text, otpPinCodeFieldController);
                    });
                  },
                  rightIcon: Icon(
                    Icons.backspace,
                    color: XploreColors.orange,
                  ),
                  rightButtonFn: () {
                    setState(() {
                      backspace(otpPinCodeFieldController);
                    });
                  },
                ),
              ),
            ],
          );
        });
  }
}
