import 'package:flutter/material.dart';
import 'package:xplore/presentation/core/widgets/unrecoverable_error_widget.dart';
import 'package:xplore/presentation/core/xplore_root.dart';
import 'package:xplore/presentation/dashboard/pages/Base.dart';
import 'package:xplore/presentation/onboarding/pages/landing_page.dart';
import 'package:xplore/presentation/onboarding/pages/onboarding.dart';
import 'package:xplore/presentation/onboarding/pages/phone_login.dart';
import 'package:xplore/presentation/onboarding/pages/phone_signup.dart';
import 'package:xplore/presentation/routes/routes.dart';

class AppRouterGenerator {
  static Route<dynamic>? generateRoute(RouteSettings? settings) {
    // final dynamic args = settings?.arguments;

    switch (settings?.name) {
      case onboardingPageRoute:
        return MaterialPageRoute<Onboarding>(builder: (_) => Onboarding());

      case landingPageRoute:
        return MaterialPageRoute<LandingPage>(builder: (_) => LandingPage());
      case siginPageRoute:
        return MaterialPageRoute<PhoneLogin>(builder: (_) => PhoneLogin());
      case sigupPageRoute:
        return MaterialPageRoute<PhoneSignup>(builder: (_) => PhoneSignup());
      case dashPageRoute:
        return MaterialPageRoute<Base>(builder: (_) => Base());
      case loginPageRoute:
        return MaterialPageRoute<Scaffold>(
            builder: (_) => Scaffold(
                  body: Container(
                    child: Center(
                      child: const Text(
                          'This is the **LoginPage**, it it not yet done'),
                    ),
                  ),
                ));

      case homePageRoute:
        return MaterialPageRoute<Scaffold>(
            builder: (_) => Scaffold(
                  body: Container(
                    child: Center(
                      child: const Text(
                          'This is the **Homepage**, it it not yet done'),
                    ),
                  ),
                ));

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute<XploreAppRoot>(
      builder: (_) => const UnrecoverableErrorWidget(),
    );
  }
}
