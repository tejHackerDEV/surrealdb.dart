import 'package:get_it/get_it.dart';

import '../../data/repository.dart';
import '../../use_cases/get_db_info.dart';
import '../utils/builders.dart';
import '../view_model.dart';
import 'view_model.dart';

class DashboardPageViewModelBuilder extends ViewModelBuilder {
  @override
  ViewModel? builder() {
    return DashboardPageViewModel(
      GetDBInfoUseCase(
        GetIt.instance.get<Repository>(),
      ),
    );
  }
}
