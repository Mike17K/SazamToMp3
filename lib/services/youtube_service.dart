import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sazamtomp3/services/youtube_service_exceptions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as path;

class YouTubeService {
  static final YouTubeService _youTubeService = YouTubeService._internal();
  factory YouTubeService() => _youTubeService;
  YouTubeService._internal();

  final YoutubeExplode ytExplode = YoutubeExplode();
  SearchClient searchClient = SearchClient(YoutubeHttpClient());

  String? _videoId; 
  Stream? _stream;
  Video? _video;  

  Future<void> downloadVideoOnDevice() async {
    final musicPath = (await getDownloadsDirectory())?.path;
    if (musicPath == null) throw DownloadsDirectoryDidntFoundException();
    if (_video == null) throw VideoNotDefinedException();
    if (_stream == null) throw StreamNotDefinedException();
    String filePath = path.join(musicPath, "${_video!.title}.mp3");

    await fetchVideo();

    // ask for storage permission
    if(! await Permission.storage.isGranted) {
      PermissionStatus status = await Permission.storage.request();
      if(! status.isGranted) {
        throw PermissionDeniedException();
      }
    }

    File file = File(filePath);
    file.createSync();

    var output = file.openWrite();
    await _stream!.pipe(output);
    await output.close();

    return;
  }
  
  Future<void> fetchVideo() async {
    try {
      _video = await ytExplode.videos.get(_videoId);
      if (_video == null) throw VideoNotFoundException();

      // download all the video
      var manifest = await ytExplode.videos.streamsClient.getManifest(_videoId);
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      _stream = ytExplode.videos.streamsClient.get(streamInfo);      

    } catch (e) {
      print('Error fetching video info: $e');
    } finally {
      ytExplode.close(); // Dispose of the YouTubeExplode object.
    }
  }

  Future<List<Video>> search(String keyword) async {
    VideoSearchList results = await searchClient.search(keyword);
    List<Video> videos = results.take(10).toList();
    return videos;
  }
}