import 'package:flutter/material.dart';
import 'package:sazamtomp3/services/audio_player_service.dart';
import 'package:sazamtomp3/services/youtube_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  final YouTubeService _youTubeService = YouTubeService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  String? videoId;
  Duration timeStump = Duration.zero;
  bool isPoused = true;

  @override
  void initState() {
    super.initState();
    videoId = _youTubeService.videoId;

    _audioPlayerService.setVolume(1.0);
    _audioPlayerService.onPositionChanged.listen((event) {
      setState(() {
        timeStump = event!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Video video = ModalRoute.of(context)!.settings.arguments as Video;

    return Scaffold(
      appBar: AppBar(
        title: Text(video.title),
      ),
      body: Center(
            child: Column(
              children: [
                Image.network(video.thumbnails.highResUrl),
                const SizedBox(height: 20),
                Center(child: Text(video.title, style: const TextStyle(fontSize: 20))), // add animation for title to roll
                const SizedBox(height: 10),
                Text(video.description),
                ElevatedButton(onPressed: () async {
                  await _youTubeService.downloadVideoOnDevice();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Downloaded"))
                  );
                },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ), 
                  child: const Text('Download')
                ),
                const SizedBox(height: 50),
                LinearProgressIndicator(
                  value: timeStump.inSeconds / video.duration!.inSeconds,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: (){
                      _audioPlayerService.seek(timeStump - const Duration(seconds: 10));
                      setState(() {
                        if (timeStump - const Duration(seconds: 10) < Duration.zero){
                          timeStump = Duration.zero;
                        } 
                        else{
                          timeStump = timeStump - const Duration(seconds: 10);
                        }
                      });
                    }, icon: const Icon(Icons.replay_10)),
                    IconButton(onPressed: (){
                      if(isPoused){
                        if (timeStump == Duration.zero) {
                          _audioPlayerService.play();
                          }
                        else {
                          _audioPlayerService.resume();
                          }
        
                        setState(() {
                          isPoused = false;
                        });
                      }else{
                        _audioPlayerService.pause();
                        setState(() {
                          isPoused = true;
                        });
                      }
                    }, icon: Icon(isPoused? Icons.play_arrow: Icons.pause)),
                    IconButton(onPressed: (){
                      _audioPlayerService.seek(timeStump + const Duration(seconds: 10));
                      setState(() {
                        setState(() {                    
                          if (timeStump + const Duration(seconds: 10) > video.duration!){
                            timeStump = video.duration!;
                          } 
                          else{
                            timeStump = timeStump + const Duration(seconds: 10);
                          }
                        });
                      });
                    }, icon: const Icon(Icons.forward_10)),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
