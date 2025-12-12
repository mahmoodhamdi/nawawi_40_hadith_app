import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/core/constants.dart';
import 'package:hadith_nawawi_audio/cubit/audio_player_cubit.dart';

void main() {
  group('AudioPlayerState', () {
    test('default state has correct initial values', () {
      const state = AudioPlayerState();

      expect(state.isPlaying, false);
      expect(state.isLoading, true);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.playbackSpeed, AudioConstants.defaultPlaybackSpeed);
      expect(state.errorMessage, isNull);
    });

    test('can create state with custom values', () {
      const state = AudioPlayerState(
        isPlaying: true,
        isLoading: false,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 5),
        playbackSpeed: 1.5,
        errorMessage: 'Test error',
      );

      expect(state.isPlaying, true);
      expect(state.isLoading, false);
      expect(state.position, const Duration(seconds: 30));
      expect(state.duration, const Duration(minutes: 5));
      expect(state.playbackSpeed, 1.5);
      expect(state.errorMessage, 'Test error');
    });

    test('copyWith updates isPlaying', () {
      const state = AudioPlayerState();
      final newState = state.copyWith(isPlaying: true);

      expect(newState.isPlaying, true);
      expect(newState.isLoading, state.isLoading);
      expect(newState.position, state.position);
    });

    test('copyWith updates isLoading', () {
      const state = AudioPlayerState();
      final newState = state.copyWith(isLoading: false);

      expect(newState.isLoading, false);
      expect(newState.isPlaying, state.isPlaying);
    });

    test('copyWith updates position', () {
      const state = AudioPlayerState();
      final newState = state.copyWith(position: const Duration(seconds: 45));

      expect(newState.position, const Duration(seconds: 45));
      expect(newState.duration, state.duration);
    });

    test('copyWith updates duration', () {
      const state = AudioPlayerState();
      final newState = state.copyWith(duration: const Duration(minutes: 10));

      expect(newState.duration, const Duration(minutes: 10));
      expect(newState.position, state.position);
    });

    test('copyWith updates playbackSpeed', () {
      const state = AudioPlayerState();
      final newState = state.copyWith(playbackSpeed: 2.0);

      expect(newState.playbackSpeed, 2.0);
    });

    test('copyWith updates errorMessage', () {
      const state = AudioPlayerState();
      final newState = state.copyWith(errorMessage: 'New error');

      expect(newState.errorMessage, 'New error');
    });

    test('copyWith clears errorMessage when not provided', () {
      const state = AudioPlayerState(errorMessage: 'Old error');
      final newState = state.copyWith(isPlaying: true);

      // errorMessage should be null when not explicitly provided
      expect(newState.errorMessage, isNull);
    });

    test('copyWith can update multiple properties', () {
      const state = AudioPlayerState();
      final newState = state.copyWith(
        isPlaying: true,
        isLoading: false,
        position: const Duration(seconds: 15),
        duration: const Duration(minutes: 3),
        playbackSpeed: 1.25,
      );

      expect(newState.isPlaying, true);
      expect(newState.isLoading, false);
      expect(newState.position, const Duration(seconds: 15));
      expect(newState.duration, const Duration(minutes: 3));
      expect(newState.playbackSpeed, 1.25);
    });

    test('props contains all properties', () {
      const state = AudioPlayerState(
        isPlaying: true,
        isLoading: false,
        position: Duration(seconds: 10),
        duration: Duration(minutes: 2),
        playbackSpeed: 1.5,
        errorMessage: 'Error',
      );

      expect(state.props, [
        true, // isPlaying
        false, // isLoading
        const Duration(seconds: 10), // position
        const Duration(minutes: 2), // duration
        1.5, // playbackSpeed
        'Error', // errorMessage
      ]);
    });

    test('states with same values are equal', () {
      const state1 = AudioPlayerState(
        isPlaying: true,
        isLoading: false,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 5),
        playbackSpeed: 1.0,
      );
      const state2 = AudioPlayerState(
        isPlaying: true,
        isLoading: false,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 5),
        playbackSpeed: 1.0,
      );

      expect(state1, equals(state2));
    });

    test('states with different isPlaying are not equal', () {
      const state1 = AudioPlayerState(isPlaying: true);
      const state2 = AudioPlayerState(isPlaying: false);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different isLoading are not equal', () {
      const state1 = AudioPlayerState(isLoading: true);
      const state2 = AudioPlayerState(isLoading: false);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different positions are not equal', () {
      const state1 = AudioPlayerState(position: Duration(seconds: 10));
      const state2 = AudioPlayerState(position: Duration(seconds: 20));

      expect(state1, isNot(equals(state2)));
    });

    test('states with different durations are not equal', () {
      const state1 = AudioPlayerState(duration: Duration(minutes: 5));
      const state2 = AudioPlayerState(duration: Duration(minutes: 10));

      expect(state1, isNot(equals(state2)));
    });

    test('states with different playback speeds are not equal', () {
      const state1 = AudioPlayerState(playbackSpeed: 1.0);
      const state2 = AudioPlayerState(playbackSpeed: 1.5);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different error messages are not equal', () {
      const state1 = AudioPlayerState(errorMessage: 'Error 1');
      const state2 = AudioPlayerState(errorMessage: 'Error 2');

      expect(state1, isNot(equals(state2)));
    });

    test('state with null error message differs from state with error', () {
      const state1 = AudioPlayerState();
      const state2 = AudioPlayerState(errorMessage: 'Some error');

      expect(state1, isNot(equals(state2)));
    });
  });

  group('AudioConstants', () {
    test('skip duration is configured correctly', () {
      expect(AudioConstants.skipDurationSeconds, 10);
      expect(
        AudioConstants.skipDuration,
        const Duration(seconds: 10),
      );
    });

    test('default playback speed is 1.0', () {
      expect(AudioConstants.defaultPlaybackSpeed, 1.0);
    });

    test('playback speed options are available', () {
      expect(AudioConstants.playbackSpeedOptions, isNotEmpty);
      expect(AudioConstants.playbackSpeedOptions, contains(1.0));
      expect(AudioConstants.playbackSpeedOptions, contains(0.5));
      expect(AudioConstants.playbackSpeedOptions, contains(1.5));
      expect(AudioConstants.playbackSpeedOptions, contains(2.0));
    });

    test('playback speed options are sorted', () {
      final options = AudioConstants.playbackSpeedOptions;
      for (int i = 0; i < options.length - 1; i++) {
        expect(options[i] < options[i + 1], isTrue);
      }
    });
  });

  group('AssetPaths', () {
    test('audio file path is generated correctly', () {
      expect(AssetPaths.audioFile(1), 'assets/audio/audio_1.mp3');
      expect(AssetPaths.audioFile(10), 'assets/audio/audio_10.mp3');
      expect(AssetPaths.audioFile(42), 'assets/audio/audio_42.mp3');
    });

    test('hadith JSON path is correct', () {
      expect(AssetPaths.hadithJson, 'assets/json/40-hadith-nawawi.json');
    });
  });

  // Note: Testing the actual AudioPlayerCubit requires mocking just_audio AudioPlayer
  // which is complex. The state tests above cover the state management logic.
  // Integration tests would be more appropriate for testing the full audio playback flow.
}
