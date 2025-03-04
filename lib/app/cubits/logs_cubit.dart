import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../configs/app_config.dart';
import '../flavor.dart';
import '../logs.dart';

class LogCubit extends Cubit<void> {
  LogService? _logService;

  LogCubit() : super(null);

  Future<void> initialize() async {
    if (FlavorService.instance.config.enableSaveLog) {
      try {
        _logService = await LogService.instance(fileName: kLogFile);
        _logService!.i('LogService initialized');
      } catch (e) {
        debugPrint('Error initializing LogService: $e');
      }
    }
  }

  @override
  Future<void> close() async {
    super.close();
    if (_logService != null) {
      await _logService!.close();
      _logService = null;
      debugPrint('LogService closed');
    }
  }
}
