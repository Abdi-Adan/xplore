import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:xplore/application/core/services/helpers.dart';
import 'package:xplore/application/core/themes/colors.dart';
import 'package:xplore/application/redux/states/app_state.dart';
import 'package:xplore/application/singletons/button_status.dart';
import 'package:xplore/domain/routes/routes.dart';
import 'package:xplore/domain/value_objects/app_spaces.dart';
import 'package:xplore/domain/value_objects/app_strings.dart';
import 'package:xplore/presentation/onboarding/widgets/input/keyboard.dart';
import 'package:xplore/presentation/onboarding/widgets/keyboard_scaffold.dart';
import 'package:xplore/presentation/onboarding/widgets/action_button.dart';
import 'package:xplore/presentation/onboarding/widgets/input/login_phone_field.dart';
import 'package:xplore/presentation/onboarding/widgets/login_title.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({Key? key}) : super(key: key);

  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  late GlobalKey<FormState>? _formKey = GlobalKey<FormState>();
  late TextEditingController phoneNumberController;

  String initialCountryCode = 'KE';
  PhoneNumber number = PhoneNumber(isoCode: 'KE');

  String phone = "";
  String isoCode = "";

  @override
  void initState() {
    super.initState();
    phoneNumberController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardScaffold(
      onLeadingTap: () {
        StoreProvider.dispatch<AppState>(
          context,
          NavigateAction.pop(),
        );
      },
      actions: [
        InkWell(
          key: ValueKey('XploreAppbar_action1'),
          onTap: () {},
          child: Icon(
            Icons.admin_panel_settings,
            color: XploreColors.orange,
          ),
        ),
        hSize30SizedBox
      ],
      widgets: [
        ...titles(
          context: context,
          extraHeading: 'We will send you a confirmation code to verify you.',
          subtitle: 'mobile number',
          title: 'Enter your \n',
        ),
        vSize20SizedBox,
        Form(
          key: _formKey,
          child: PhoneLoginField(
            number: number,
            onInputChanged: () {},
            onInputValidated: () {},
            onSaved: () {},
            phoneNumberController: phoneNumberController,
          ),
        ),
        vSize40SizedBox,
        ActionButton(
          widgetText: nextText,
          nextRoute: otpPageRoute,
          statusStream: ButtonStatusStore().statusStream,
          colorStream: ButtonStatusStore().colorStream,
          onTapcallback: () {
            setState(() {
              
            });
          },
        ),
        vSize30SizedBox,
        Container(
          child: LoginKeyboard(
            onKeyTap: (String text) {
              setState(() {
                insertText(text, phoneNumberController);
              });
            },
            rightKey: Icon(
              Icons.backspace,
              color: XploreColors.orange,
            ),
            onRightKeyTap: () {
              setState(() {
                removeText(phoneNumberController);
              });
            },
          ),
        ),
      ],
    );
  }
}
