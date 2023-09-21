import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {

  static final AudioPlayerService _audioPlayerService = AudioPlayerService._internal();
  factory AudioPlayerService() => _audioPlayerService;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  Source? _focusedSource;

  List<int>? _bytes;

  void setBytes(List<int> bytes) {
    _bytes = bytes;
  }

  List<int>? get bytes => _bytes;

  Future<void> setSourceFromStream(Stream<List<int>> stream) async {
    _focusedSource = BytesSource(Uint8List.fromList((await stream.toList()).expand((element) => element).toList()));
    if(_focusedSource!=null) _audioPlayer.play(_focusedSource!);
  }

  Future<void> play() {
    print("PLAY");
    if(_focusedSource == null) return Future.value();
    print("PLAY000");
    return _audioPlayer.play(_focusedSource!);
  }

  Future<void> pause() {
    if(_focusedSource == null) return Future.value();
    return _audioPlayer.pause();
  }
  
  Future<void> resume() {
    print("RESUME");
    if(_focusedSource == null) return Future.value();
    return _audioPlayer.resume();
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

  void setSource(Source source) {
    _focusedSource = source;
  }

  Stream<Duration?> get onPositionChanged => _audioPlayer.onPositionChanged;
  Future<Duration?> get duration => _audioPlayer.getDuration();
  
}