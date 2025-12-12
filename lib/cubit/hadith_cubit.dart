import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/hadith_loader.dart';
import 'hadith_state.dart';

/// Cubit responsible for managing hadith data state
class HadithCubit extends Cubit<HadithState> {
  HadithCubit() : super(HadithInitial());

  /// Fetches all hadiths from the data source
  ///
  /// Emits [HadithLoading] while fetching, then either
  /// [HadithLoaded] on success or [HadithError] on failure
  Future<void> fetchHadiths() async {
    emit(HadithLoading());
    try {
      final hadiths = await HadithLoader.loadHadiths();
      emit(HadithLoaded(hadiths));
    } on HadithLoadException catch (e) {
      debugPrint('HadithLoadException: ${e.message}');
      if (e.originalError != null) {
        debugPrint('Original error: ${e.originalError}');
      }
      emit(HadithError(e.message));
    } catch (e) {
      debugPrint('Unexpected error loading hadiths: $e');
      emit(HadithError('حدث خطأ غير متوقع أثناء تحميل الأحاديث'));
    }
  }
}
