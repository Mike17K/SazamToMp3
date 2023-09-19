import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {

  static final AudioPlayerService _audioPlayerService = AudioPlayerService._internal();
  factory AudioPlayerService() => _audioPlayerService;
  AudioPlayerService._internal();

  AudioPlayer _audioPlayer = AudioPlayer();
  Source? _focusedSource;

  Future<void> play() {
    if(_focusedSource == null) return Future.value();
    return _audioPlayer.play(_focusedSource!);
  }

  Future<void> pause() {
    if(_focusedSource == null) return Future.value();
    return _audioPlayer.pause();
  }

  Future<void> stop() {
    if(_focusedSource == null) return Future.value();
    return _audioPlayer.stop();
  }

  Future<void> setVolume(double volume) {
    if(_focusedSource == null) return Future.value();
    return _audioPlayer.setVolume(volume);
  }

  Future<void> seek(Duration position) {
    if(_focusedSource == null) return Future.value();
    return _audioPlayer.seek(position);
  }

  Future<void> setSource(Source source) async {
    _focusedSource = source;
  }
  
}