import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/hadith_loader.dart';
import 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  HadithCubit() : super(HadithInitial());

  Future<void> fetchHadiths() async {
    emit(HadithLoading());
    try {
      final hadiths = await HadithLoader.loadHadiths();
      emit(HadithLoaded(hadiths));
    } catch (e) {
      emit(HadithError("فشل تحميل الأحاديث"));
    }
  }
}
