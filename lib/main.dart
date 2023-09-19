import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as path;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('YouTube Video Info'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: fetchVideoInfo,
            child: Text('Fetch Video Info'),
          ),
        ),
      ),
    );
  }

  void fetchVideoInfo() async {
    var ytExplode = YoutubeExplode();

    var videoId = 'Xh8bTrX50UE'; // Replace with the YouTube video ID you want to fetch info for.

    try {
      var video = await ytExplode.videos.get(videoId);
      print('Title: ${video.title}');
      print('Author: ${video.author}');
      print('Duration: ${video.duration}');
      // You can access more information about the video, like description, keywords, and more.

      // download all the video
      var manifest = await ytExplode.videos.streamsClient.getManifest(videoId);
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      var stream = ytExplode.videos.streamsClient.get(streamInfo);

      // create a file      
      String musicPath = await getMusicDirectoryPath();

      String filePath = path.join(musicPath, "${video.title}.mp3");
      print(filePath);

      // ask for storage permission
      if(! await Permission.storage.isGranted) {
        PermissionStatus status = await Permission.storage.request();
        if(! status.isGranted) {
        return;
        }
      }

      File file = File(filePath);
      file.createSync();

      var output = file.openWrite();
      await stream.pipe(output);
      await output.close();

      // play the audio    
      AudioPlayer audioPlayer = playAudio(filePath);
      audioPlayer.setVolume(1.0);
      await Future.delayed(Duration(seconds: 10));
      await Future.delayed(Duration(seconds: 10));
      audioPlayer.setVolume(0.5);
      await Future.delayed(Duration(seconds: 5));
      audioPlayer.setVolume(1.0);
      audioPlayer.resume();

      

    } catch (e) {
      print('Error fetching video info: $e');
    } finally {
      ytExplode.close(); // Dispose of the YouTubeExplode object.
    }
  }
  
AudioPlayer playAudio(String audioPath) {
  
  Source audioSource = BytesSource( File(audioPath).readAsBytesSync() );

  AudioPlayer audioPlayer = AudioPlayer();
  audioPlayer.play(audioSource);

  return audioPlayer;
}

Future<String> getMusicDirectoryPath() async {

  String? downloadsDirectoryPath = (await getDownloadsDirectory())?.path;
  return downloadsDirectoryPath!;
  
}



}


