import 'package:get_it/get_it.dart';

import '../../data/repository.dart';
import '../../use_cases/sign_in.dart';
import '../utils/builders.dart';
import '../view_model.dart';
import 'view_model.dart';

class SignInPageViewModelBuilder extends ViewModelBuilder {
  @override
  ViewModel? builder() {
    return SignInPageViewModel(
      SignInUseCase(
        GetIt.instance.get<Repository>(),
      ),
    );
  }
}
