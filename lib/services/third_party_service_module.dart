import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';

@module
abstract class ThirdPartyServicesModule {
  @lazySingleton
  NavigationService get navigationService => NavigationService();

  @lazySingleton
  DialogService get dialogService => DialogService();

  @lazySingleton
  SnackbarService get snackbarService => SnackbarService();
}