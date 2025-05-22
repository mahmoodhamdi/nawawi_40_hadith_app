import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/preferences_service.dart';
import 'last_read_state.dart';

class LastReadCubit extends Cubit<LastReadState> {
  LastReadCubit() : super(const LastReadState()) {
    loadLastReadInfo();
  }

  // Load last read hadith information from preferences
  Future<void> loadLastReadInfo() async {
    final hadithIndex = await PreferencesService.getLastReadHadith();
    final lastReadTime = await PreferencesService.getLastReadTime();

    emit(LastReadState(hadithIndex: hadithIndex, lastReadTime: lastReadTime));
  }

  // Update the last read hadith information
  Future<void> updateLastReadHadith(int hadithIndex) async {
    final now = DateTime.now();

    // Save to preferences
    await PreferencesService.saveLastReadHadith(hadithIndex);

    // Update state
    emit(LastReadState(hadithIndex: hadithIndex, lastReadTime: now));
  }

  // Clear last read data
  Future<void> clearLastReadData() async {
    await PreferencesService.clearLastReadData();
    emit(const LastReadState());
  }
}
