import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sazamtomp3/services/audio_player_service.dart';
import 'package:sazamtomp3/services/youtube_service_exceptions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as path;

class YouTubeService {
  static final YouTubeService _youTubeService = YouTubeService._internal();
  factory YouTubeService() => _youTubeService;
  YouTubeService._internal();

  final YoutubeExplode ytExplode = YoutubeExplode();
  SearchClient searchClient = SearchClient(YoutubeHttpClient());
  AudioPlayerService _audioService = AudioPlayerService();

  String? _videoId; 
  Stream<List<int>>? _stream;
  Video? _video;  

  String? get videoId => _videoId;
  get stream => _stream;

  void setVideoId(String videoId) {
    _videoId = videoId;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    }
    return false;
  }

  Future<void> downloadVideoOnDevice() async {
    String musicPath = "${(await getDownloadsDirectory())?.path.split("0")[0]}0/Download";

    if (await _requestPermission(Permission.storage)) {
      final directory = await getExternalStorageDirectory();
      String newPath = "";
      List<String> paths = directory!.path.split("/");
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          newPath += "/" + folder;
        } else {
          break;
        }
      }
      musicPath = newPath + "/Download"; //"/TeamTrackPro";
    }


    if (_video == null) throw VideoNotDefinedException();
    if (_stream == null) throw StreamNotDefinedException();
    String filePath = path.join(musicPath, "${_video!.title}.mp3");

    List<int> data = _audioService.bytes ?? [];

    // ask for storage permission
    print("Permission ${await Permission.storage.isGranted}");
    if(! await Permission.storage.isGranted) {
      PermissionStatus status = await Permission.storage.request();
      if(! status.isGranted) {
        throw PermissionDeniedException();
      }
    }

    File file = File(filePath);
    file.createSync();

    print(filePath);

    var output = file.openWrite();
    output.add(data);
    await output.close();

    return;
  }
  
  Future<void> fetchVideo() async {
    _video = await ytExplode.videos.get(_videoId);
    if (_video == null) throw VideoNotFoundException();

    // download all the video
    var manifest = await ytExplode.videos.streamsClient.getManifest(_videoId);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    _stream = ytExplode.videos.streamsClient.get(streamInfo);  

    if (_stream == null) throw StreamNotFoundException();
    
    final bytes = (await _stream!.toList()).expand((element) => element).toList();
    final focusedSource = BytesSource(Uint8List.fromList(bytes));
    _audioService.setSource(focusedSource);
    _audioService.setBytes(bytes);

    print("Video fetched successfully");
  }

  Future<List<Video>> search(String keyword) async {
    VideoSearchList results = await searchClient.search(keyword);
    List<Video> videos = results.take(10).toList();
    return videos;
  }
}