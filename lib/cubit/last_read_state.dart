import 'package:equatable/equatable.dart';

class LastReadState extends Equatable {
  final int? hadithIndex;
  final DateTime? lastReadTime;

  const LastReadState({this.hadithIndex, this.lastReadTime});

  @override
  List<Object?> get props => [hadithIndex, lastReadTime];

  LastReadState copyWith({int? hadithIndex, DateTime? lastReadTime}) {
    return LastReadState(
      hadithIndex: hadithIndex ?? this.hadithIndex,
      lastReadTime: lastReadTime ?? this.lastReadTime,
    );
  }
}
