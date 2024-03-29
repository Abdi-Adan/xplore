import 'package:get_it/get_it.dart';
import 'package:shamiri/features/feature_merchant_store/data/repository/merchant_repository_impl.dart';
import 'package:shamiri/features/feature_merchant_store/domain/repository/merchant_repository.dart';
import 'package:shamiri/features/feature_merchant_store/domain/use_cases/add_product_to_firestore.dart';
import 'package:shamiri/features/feature_merchant_store/domain/use_cases/delete_product.dart';
import 'package:shamiri/features/feature_merchant_store/domain/use_cases/delete_product_pic.dart';
import 'package:shamiri/features/feature_merchant_store/domain/use_cases/get_merchant_products.dart';
import 'package:shamiri/features/feature_merchant_store/domain/use_cases/merchant_use_cases.dart';
import 'package:shamiri/features/feature_merchant_store/domain/use_cases/update_product.dart';

void merchantDI({required GetIt locator}) {
  /// Merchant Repository
  locator.registerLazySingleton<MerchantRepository>(
      () => MerchantRepositoryImpl());

  /// Merchant Use Cases
  locator.registerLazySingleton<MerchantUseCases>(() => MerchantUseCases(
      addProductToFirestore: AddProductToFirestore(),
      getMerchantProducts: GetMerchantProducts(),
      updateProduct: UpdateProduct(),
      deleteProduct: DeleteProduct(),
      deleteProductPic: DeleteProductPic()));
}
