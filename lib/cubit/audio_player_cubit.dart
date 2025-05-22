import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

// Audio Player State
class AudioPlayerState extends Equatable {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final String? errorMessage;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = true,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.errorMessage,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isPlaying,
        isLoading,
        position,
        duration,
        playbackSpeed,
        errorMessage,
      ];
}

// Audio Player Cubit
class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  late AudioPlayer _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  AudioPlayerCubit() : super(const AudioPlayerState()) {
    _player = AudioPlayer();
    _initStreams();
  }

  void _initStreams() {
    _positionSub = _player.positionStream.listen((pos) {
      emit(state.copyWith(position: pos));
    });

    _playerStateSub = _player.playerStateStream.listen((playerState) {
      emit(state.copyWith(isPlaying: playerState.playing));
    });
  }

  // Load audio for a specific hadith index
  Future<void> loadAudio(int hadithIndex) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      // Renamed asset file to audio_1.mp3, audio_2.mp3, etc.
      final path = 'assets/audio/audio_$hadithIndex.mp3';
      debugPrint('Loading audio from path: $path');

      await _player.setAsset(path);
      final duration = _player.duration ?? Duration.zero;
      emit(state.copyWith(
        duration: duration,
        isLoading: false,
      ));
      debugPrint('Audio loaded successfully. Duration: $duration');
    } catch (e, stackTrace) {
      debugPrint('Error loading audio: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الملف الصوتي: ${e.toString()}',
      ));
    }
  }

  // Play/Pause toggle
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  // Seek to position
  void seekTo(Duration position) {
    _player.seek(position);
  }

  // Skip forward
  void skipForward() {
    final newPos = state.position + const Duration(seconds: 10);
    if (newPos < state.duration) {
      seekTo(newPos);
    } else {
      seekTo(state.duration);
    }
  }

  // Skip backward
  void skipBackward() {
    final newPos = state.position - const Duration(seconds: 10);
    if (newPos > Duration.zero) {
      seekTo(newPos);
    } else {
      seekTo(Duration.zero);
    }
  }

  // Replay audio
  Future<void> replay() async {
    _player.seek(Duration.zero);
    if (!state.isPlaying) {
      await _player.play();
    }
  }

  // Change playback speed
  Future<void> changePlaybackSpeed(double speed) async {
    await _player.setSpeed(speed);
    emit(state.copyWith(playbackSpeed: speed));
  }

  // Pause audio
  Future<void> pause() async {
    if (_player.playing) {
      await _player.pause();
    }
  }

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    await _playerStateSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
