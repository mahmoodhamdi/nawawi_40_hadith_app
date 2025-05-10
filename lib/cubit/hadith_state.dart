import 'package:equatable/equatable.dart';
import '../models/hadith.dart';

abstract class HadithState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithLoaded extends HadithState {
  final List<Hadith> hadiths;

  HadithLoaded(this.hadiths);

  @override
  List<Object?> get props => [hadiths];
}

class HadithError extends HadithState {
  final String message;

  HadithError(this.message);

  @override
  List<Object?> get props => [message];
}
