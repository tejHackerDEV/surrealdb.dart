import 'package:get_it/get_it.dart';

import '../../data/repository.dart';
import '../../use_cases/delete_table_record_by_thing.dart';
import '../../use_cases/get_db_info.dart';
import '../../use_cases/get_records_count.dart';
import '../../use_cases/get_table_records.dart';
import '../utils/builders.dart';
import '../view_model.dart';
import 'view_model.dart';

class DashboardPageViewModelBuilder extends ViewModelBuilder {
  @override
  ViewModel? builder() {
    final repository = GetIt.instance.get<Repository>();
    return DashboardPageViewModel(
      GetDBInfoUseCase(repository),
      GetTableRecordsUseCase(repository),
      GetRecordsCountUseCase(repository),
      DeleteTableRecordByThingUseCase(repository),
    );
  }
}
