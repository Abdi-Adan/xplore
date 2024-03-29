import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shamiri/core/presentation/controller/auth_controller.dart';
import 'package:shamiri/core/presentation/controller/core_controller.dart';
import 'package:shamiri/core/presentation/controller/user_prefs_controller.dart';
import 'package:shamiri/features/feature_cart/presentation/controller/cart_controller.dart';
import 'package:shamiri/features/feature_home/presentation/controller/home_controller.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/controller/merchant_controller.dart';

void initializeControllers() {
  Get.lazyPut(() => AuthController(), fenix: true);
  Get.lazyPut(() => CoreController(), fenix: true);
  Get.lazyPut(() => HomeController(), fenix: true);
  Get.lazyPut(() => UserPrefsController(), fenix: true);
  Get.lazyPut(() => MerchantController(), fenix: true);
  Get.lazyPut(() => CartController(), fenix: true);
}
